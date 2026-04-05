import React, { useState } from 'react';
import axios from 'axios';

const TextSummarizer = () => {
  const [text, setText] = useState('');
  const [summary, setSummary] = useState('');
  const [loading, setLoading] = useState(false);
  
  const handleSummarize = async () => {
    if (!text.trim()) return;
    
    setLoading(true);
    try {
      const response = await axios.post('/llm/summarize', { text });
      setSummary(response.data.summary);
    } catch (error) {
      setSummary('Error summarizing text');
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="text-summarizer">
      <h3>Text Summarizer</h3>
      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Enter text to summarize..."
        rows={10}
        className="form-control"
      />
      <button 
        onClick={handleSummarize} 
        disabled={loading || !text.trim()}
        className="btn btn-primary mt-2"
      >
        {loading ? 'Summarizing...' : 'Summarize'}
      </button>
      {summary && (
        <div className="mt-3 p-3 border">
          <h4>Summary:</h4>
          <p>{summary}</p>
        </div>
      )}
    </div>
  );
};

export default TextSummarizer;