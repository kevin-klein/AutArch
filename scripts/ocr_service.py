import torch
import torch.nn.functional as F
from transformers import AutoProcessor, AutoModelForCausalLM
import io
import base64
from PIL import Image
import numpy as np
import json

# Load Qwen3.5 model for text extraction
# In production, this would be loaded from a model repository
# For now, we'll use a placeholder - replace with actual model path
MODEL_NAME = "Qwen/Qwen3.5"  # Replace with actual model path
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def extract_text_from_image(image_path):
    """
    Extract text from archaeological drawing images using Qwen3.5
    Returns structured text information
    """
    try:
        # Load model and processor
        processor = AutoProcessor.from_pretrained(MODEL_NAME, trust_remote_code=True)
        model = AutoModelForCausalLM.from_pretrained(
            MODEL_NAME, 
            trust_remote_code=True,
            torch_dtype=torch.float16
        ).to(DEVICE)
        
        # Load image
        image = Image.open(image_path).convert("RGB")
        
        # Prepare inputs
        inputs = processor(
            image, 
            text="Extract all text, dimensions, and descriptions from this archaeological drawing.",
            return_tensors="pt"
        ).to(DEVICE)
        
        # Generate output
        outputs = model.generate(**inputs, max_new_tokens=512)
        
        # Decode output
        decoded_text = processor.decode(outputs[0])
        
        # Parse structured information from decoded text
        structured_info = parse_structured_text(decoded_text)
        
        return structured_info
        
    except Exception as e:
        print(f"OCR extraction error: {e}")
        return None

def parse_structured_text(text):
    """
    Parse the LLM output into structured format
    """
    import re
    
    # Extract dimensions
    dimensions = []
    dim_pattern = r"(\d+\.?\d*)\s*(cm|mm|in|mm|ft|m)?\b"
    for match in re.finditer(dim_pattern, text):
        dimensions.append({
            "value": float(match.group(1)),
            "unit": match.group(2).lower() if match.group(2) else "cm"
        })
    
    # Extract description
    description = extract_description(text)
    
    # Extract summary
    summary = extract_summary(text)
    
    # Extract key phrases
    key_phrases = extract_key_phrases(text)
    
    return {
        "dimensions": dimensions,
        "description": description,
        "summary": summary,
        "key_phrases": key_phrases,
        "raw_text": text
    }

def extract_description(text):
    """Extract description of what figure shows"""
    patterns = [
        r"shows\s+(.+?)(?:\n|$)",
        r"depicts\s+(.+?)(?:\n|$)",
        r"illustrates\s+(.+?)(?:\n|$)",
        r"figure\s+\d+.*?(?:shows|depicts|illustrates)\s+(.+?)(?:\n|$)",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            desc = match.group(1).strip()
            # Clean up
            desc = re.sub(r"^\s*[Ff]igure\s+\d+[:.\s]?", "", desc)
            desc = re.sub(r"^\s*The\s+following\s+figure\s+[:.\s]?", "", desc)
            desc = re.sub(r"^\s*The\s+left\s+figure\s+[:.\s]?", "", desc)
            desc = re.sub(r"^\s*The\s+right\s+figure\s+[:.\s]?", "", desc)
            return desc[:500] if len(desc) > 500 else desc
    
    # Fallback to first sentence
    sentences = text.split(".")
    if sentences:
        first = sentences[0].strip()
        return first[:500] if len(first) > 500 else first
    
    return None

def extract_summary(text):
    """Extract summary of key features"""
    key_terms = [
        r"(?:ceramic|vessel|pot)\b",
        r"(?:arrow\s+head|arrow)\b",
        r"(?:skeleton|bone)\b",
        r"(?:grave|burial)\b",
        r"(?:kurgan)\b",
        r"(?:bone\s+tool|stone\s+tool|lithic)\b",
        r"(?:weapon|ornament|decoration)\b",
        r"(?:rim|base|handle|loop)\b"
    ]
    
    features = []
    for pattern in key_terms:
        if re.search(pattern, text, re.IGNORECASE):
            features.append(pattern[0])
    
    if features:
        return f"Archaeological figure showing: {', '.join(features)}"
    
    return "Archaeological figure"

def extract_key_phrases(text):
    """Extract key descriptive phrases"""
    phrases = []
    
    # Look for common archaeological terms
    terms = [
        "ceramic", "pottery", "vessel", "arrow", "skeleton", 
        "grave", "burial", "kurgan", "lithic", "tool",
        "weapon", "ornament", "decoration", "handle", "rim"
    ]
    
    for term in terms:
        if re.search(rf"{term}\b", text, re.IGNORECASE):
            phrases.append(term)
    
    return list(set(phrases))

if __name__ == "__main__":
    # Test with a sample image
    test_image = "/home/kevin/AutArch/tmp/test_drawing.jpg"
    result = extract_text_from_image(test_image)
    print(json.dumps(result, indent=2) if result else "No result")
