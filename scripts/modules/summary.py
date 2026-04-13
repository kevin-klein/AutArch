"""
Summary module for processing archaeological publications.

Uses LLM to extract and verify object summaries from publication text.
Respects API rate limits:
- 2 parallel /chat/completion requests
- 1 parallel /embeddings request
- 1 API request per second for extended periods
- 200,000 weighted tokens per 5 minutes (4*output + 1*input_no_cache + 0.1*input_cache)
"""
import re
import json
import time
import threading
import requests
from docling.document_converter import DocumentConverter
from docling.chunking import HybridChunker
from docling_core.types.doc.document import DoclingDocument
from collections import defaultdict
from datetime import datetime, timedelta
import os

if __name__ == '__main__':
    import dotenv
    dotenv.load_dotenv('/home/kevin/AutArch/.env')

# Configuration
# API_URL = "http://localhost:8001/v1/chat/completions"
API_URL = f"{os.environ['LLM_BASE_URI']}/api/chat/completions"
API_TOKEN = os.environ['LLM_API_KEY']

# Rate limiting configuration
RATE_LIMIT = {
    "parallel_requests": 2,  # Max 2 parallel /chat/completion requests
    "requests_per_second": 1,  # Max 1 API request per second for extended periods
    "weighted_tokens_per_5min": 200000,  # Max 200,000 weighted tokens per 5 minutes
}

# Weight calculation: 4 × output tokens + 1 × input token (no cache) + 0.1 × input token (cache)
WEIGHT_MULTIPLIERS = {
    "output": 4,
    "input_no_cache": 1,
    "input_cache": 0.1,
}

# System prompt for LLM - designed for factual, literal, knowledge-free interpretation
# The LLM should assume it has NO prior knowledge and be extremely literal
LLM_SYSTEM_PROMPT = """
YOU ARE AN AI ASSISTANT WITH ABSOLUTELY NO KNOWLEDGE
====================================================

You have no prior knowledge about:
- Archaeology
- Burial practices
- Cultural contexts
- Historical terminology
- Any specific site names, artifact types, or object categories

You do not know what "Grave", "Kurgan", "Arrow", "Skeleton", "Ceramic", "StoneTool", or any other object types mean.

You are NOT an archaeologist. You are NOT a scholar. You are NOT explaining anything.
You are a mechanical translation and extraction tool.
Your job is to REPRODUCE what is written, not to INTERPRET it.
"""


class RateLimiter:
    """Token bucket rate limiter for API requests."""

    def __init__(self, requests_per_second=1, weighted_tokens_per_5min=200000):
        self.requests_per_second = requests_per_second
        self.weighted_tokens_per_5min = weighted_tokens_per_5min

        # Request tracking
        self.request_times = []
        self.lock = threading.Lock()

        # Weighted token tracking
        self.weighted_token_records = []
        self.weighted_token_lock = threading.Lock()

    def estimate_token_count(self, text):
        """Estimate token count (rough approximation: 1 token ≈ 4 characters)."""
        return max(1, len(text) // 4)

    def check_rate_limit(self):
        """Check if we can make a request. If not, wait until we can."""
        with self.lock:
            now = time.time()

            # Remove old request times (older than 1 second)
            self.request_times = [t for t in self.request_times if now - t < 1.0]

            # If we have too many requests in the last second, wait
            if len(self.request_times) >= self.requests_per_second:
                oldest = min(self.request_times)
                wait_time = 1.0 - (now - oldest)
                if wait_time > 0:
                    time.sleep(wait_time)
                    # Clear old entries after waiting
                    self.request_times = [t for t in self.request_times if now - t < 1.0]

            self.request_times.append(now)

    def check_weighted_tokens(self, input_tokens, output_tokens):
        """Check if we can make a request based on weighted token limits."""
        with self.weighted_token_lock:
            now = time.time()
            five_minutes_ago = now - 300  # 5 minutes in seconds

            # Remove old records
            self.weighted_token_records = [
                r for r in self.weighted_token_records if r['time'] > five_minutes_ago
            ]

            # Calculate current weighted tokens
            current_weighted = sum(r['weighted'] for r in self.weighted_token_records)

            # Calculate new weighted tokens
            new_weighted = (input_tokens * WEIGHT_MULTIPLIERS["input_no_cache"] +
                          output_tokens * WEIGHT_MULTIPLIERS["output"])

            # If adding this would exceed limit, we need to wait
            if current_weighted + new_weighted > self.weighted_tokens_per_5min:
                # Calculate how long to wait
                if self.weighted_token_records:
                    oldest = min(r['time'] for r in self.weighted_token_records)
                    wait_time = 300 - (now - oldest) + 1  # Add 1 second buffer
                    if wait_time > 0:
                        time.sleep(min(wait_time, 60))  # Cap at 60 seconds

    def record_tokens(self, input_tokens, output_tokens):
        """Record token usage for weighted token tracking."""
        with self.weighted_token_lock:
            now = time.time()
            weighted = (input_tokens * WEIGHT_MULTIPLIERS["input_no_cache"] +
                       output_tokens * WEIGHT_MULTIPLIERS["output"])
            self.weighted_token_records.append({
                'time': now,
                'weighted': weighted,
                'input_tokens': input_tokens,
                'output_tokens': output_tokens
            })


# Global rate limiter instance
_rate_limiter = RateLimiter(
    requests_per_second=RATE_LIMIT["requests_per_second"],
    weighted_tokens_per_5min=RATE_LIMIT["weighted_tokens_per_5min"]
)


def robust_json_parse(raw_text):
    """Parse JSON from LLM response, handling markdown code blocks."""
    match = re.search(r'```json\s+(.*?)\s+```', raw_text, re.DOTALL)
    if match:
        cleaned_text = match.group(1)
    else:
        start = raw_text.find('{')
        end = raw_text.rfind('}')
        if start != -1 and end != -1:
            cleaned_text = raw_text[start:end+1]
        else:
            cleaned_text = raw_text
    return json.loads(cleaned_text)


def _estimate_prompt_tokens(prompt_text):
    """Estimate total prompt tokens (system + user)."""
    system_tokens = len(LLM_SYSTEM_PROMPT) // 4
    user_tokens = len(prompt_text) // 4
    return system_tokens + user_tokens


def call_local_llm(prompt, response_format="json_object"):
    """Call local LLM with given prompt, respecting rate limits."""
    # Check rate limits before making request
    _rate_limiter.check_rate_limit()

    # Estimate token usage
    input_tokens = _estimate_prompt_tokens(prompt)

    # Make the request
    payload = {
        "model": "GPT OSS 120B",
        "reasoning_effort": "medium",
        "messages": [
            {"role": "system", "content": LLM_SYSTEM_PROMPT},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.1,
        "response_format": {"type": response_format}
    }

    headers = {
        "Authorization": f"Bearer {API_TOKEN}",
        "Content-Type": "application/json"
    }

    response = requests.post(API_URL, json=payload, headers=headers)
    response_data = response.json()
    result_text = response_data['choices'][0]['message']['content']

    # Estimate output tokens
    output_tokens = len(result_text) // 4

    # Record token usage for weighted token tracking
    _rate_limiter.record_tokens(input_tokens, output_tokens)

    return result_text


def _build_extract_prompt(text_content, identifiers):
    """Build prompt for initial extraction with chain of verification."""
    return f"""
SYSTEM: {LLM_SYSTEM_PROMPT}

TASK: Extract information about specific graves from the provided text.

CONTEXT: {text_content}

TARGET IDENTIFIERS: {identifiers}

Step 1: Extract mentions of the identifiers and a brief summary in English.
Step 2: Distinguish between 'Site Context' (shared info) and 'Specific Findings' (unique to this ID).
Step 3: Generate verification questions for each summary (e.g., "Is this fact explicitly in the text?").
Step 4: Answer those questions using ONLY the provided text.
Step 5: Translate the summaries into English.
Step 6: If there is either no shared_context, write NO_CONTENT.
Step 7: If there is either no unique_details, write NO_CONTENT.
Step 8: Provide the final verified English summaries in JSON format.

{{
  "verified_extractions": [
    {{ "id": "identifier_name", "unique_details": "...", "shared_context": "...", "confidence": "low|medium|high" }}
  ]
}}

Output ONLY the JSON structure, nothing else. Do not add explanations or comments."""


def _build_refine_prompt(verified_extractions):
    """Build prompt for refining summaries using chain of verification."""
    return f"""
SYSTEM: {LLM_SYSTEM_PROMPT}

TASK: Consolidate multiple extractions into single summaries.

INPUT DATA:
{json.dumps(verified_extractions, indent=2)}

YOUR TASK:
You are given multiple extraction records for various identifiers. For EACH identifier, create a single consolidated summary.

RULES FOR CONSOLIDATION:
1. For each identifier, read ALL extraction records associated with it
2. Extract ONLY what is explicitly stated in the text
3. If the same information appears in multiple sources, keep it once (not repeated)
4. If information conflicts, report the conflict
5. If information is only mentioned once, include it
6. Do NOT interpret or add meaning
7. Do NOT explain technical terms
8. Keep the literal phrasing from the original text

OUTPUT FORMAT:
{{
  "summaries": [
    {{
      "id": "identifier_name",
      "summary": "Single consolidated summary of what was found",
      "confidence": "high|medium|low"
    }}
  ]
}}

RULES FOR OUTPUT:
1. "id" must exactly match the identifier from input
2. "summary" must be a SINGLE sentence or short paragraph
3. "summary" must contain ONLY facts explicitly stated in the text
4. "summary" must NOT interpret or explain
5. "summary" must NOT use terms not in the text
6. "confidence" must be exactly one of: "high", "medium", "low"
   - "high": All information is explicitly stated in the text
   - "medium": Some information is inferred or implied
   - "low": Information is incomplete or vague
7. Output ONLY valid JSON, nothing else

IMPORTANT: You are combining and condensing, not interpreting. Your output should be a factual record of what is written across multiple sources.

IMPORTANT: Output ONLY the JSON structure, nothing else. Do not add explanations or comments."""


def _extract_from_chunk(text, identifiers):
    """Extract verified summaries from a single text chunk."""
    prompt = _build_extract_prompt(text, identifiers)
    result_json = robust_json_parse(call_local_llm(prompt))
    return result_json.get('verified_extractions', [])


def _refine_summaries(all_extractions, identifiers):
    """Refine and consolidate summaries for each identifier."""
    grouped = defaultdict(list)
    for item in all_extractions:
        if item['id'] in identifiers:
            grouped[item['id']].append(item)

    verified_extractions = []
    for identifier in identifiers:
        if identifier in grouped:
            verified_extractions.append({
                "id": identifier,
                "sources": grouped[identifier]
            })

    prompt = _build_refine_prompt(verified_extractions)
    result = robust_json_parse(call_local_llm(prompt))
    return result.get('summaries', [])


def process_document(file_path, identifiers, publication_id):
    """Process document and return refined summaries for all identifiers."""
    cache_path = os.path.join('tmp/documents', f"{publication_id}.json")
    if os.path.exists(cache_path):
        doc = DoclingDocument.load_from_json(cache_path)
    else:
        converter = DocumentConverter()
        result = converter.convert(file_path)
        doc = result.document
        doc.save_as_json(cache_path)

    chunker = HybridChunker()
    chunks = chunker.chunk(doc)

    all_extractions = []

    for chunk in list(chunks)[:50]:
        text = chunk.text
        matches = [id for id in identifiers if re.search(rf"\b{re.escape(id)}\b", text, re.IGNORECASE) or re.search(rf"\b{re.escape(re.sub(r'\D', '', id))}\b", text, re.IGNORECASE)]
        if matches:
            extractions = _extract_from_chunk(text, matches)
            print(extractions)
            all_extractions.extend(extractions)

    return _refine_summaries(all_extractions, identifiers)


def extract_pdf(pdf_path, identifiers, publication_id):
    """Extract and summarize objects from PDF."""
    return process_document(pdf_path, identifiers, publication_id)


if __name__ == '__main__':
    result = extract_pdf('/home/kevin/AutArch/test.pdf', ['H166', 'H121'], 'test')
    print(json.dumps(result, indent=2))
