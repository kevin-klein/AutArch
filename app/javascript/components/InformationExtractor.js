import React, { useState } from 'react';
import axios from 'axios';

const InformationExtractor = () => {
  const [text, setText] = useState('');
  const [extractedInfo, setExtractedInfo] = useState(null);
  const [loading, setLoading] = useState(false);
  
  const handleExtractInfo = async () => {
    if (!text.trim()) return;
    
    setLoading(true);
    try {
      const response = await axios.post('/llm/extract_info', { text });
      setExtractedInfo(response.data.extracted_info);
    } catch (error) {
      setExtractedInfo({ error: 'Error extracting information' });
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="information-extractor">
      <h3>Information Extractor</h3>
      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Enter text to extract information from..."
        rows={10}
        className="form-control"
      />
      <button 
        onClick={handleExtractInfo} 
        disabled={loading || !text.trim()}
        className="btn btn-primary mt-2"
      >
        {loading ? 'Extracting...' : 'Extract Information'}
      </button>
      {extractedInfo && (
        <div className="mt-3 p-3 border">
          <h4>Extracted Information:</h4>
          {extractedInfo.error ? (
            <p className="text-danger">{extractedInfo.error}</p>
          ) : (
            <div>
              {extractedInfo.locations && extractedInfo.locations.length > 0 && (
                <div className="mb-3">
                  <h5>Locations:</h5>
                  <ul>
                    {extractedInfo.locations.map((location, index) => (
                      <li key={index}>{location}</li>
                    ))}
                  </ul>
                </div>
              )}
              {extractedInfo.dates && extractedInfo.dates.length > 0 && (
                <div className="mb-3">
                  <h5>Dates:</h5>
                  <ul>
                    {extractedInfo.dates.map((date, index) => (
                      <li key={index}>{date}</li>
                    ))}
                  </ul>
                </div>
              )}
              {extractedInfo.artifacts && extractedInfo.artifacts.length > 0 && (
                <div className="mb-3">
                  <h5>Artifacts:</h5>
                  <ul>
                    {extractedInfo.artifacts.map((artifact, index) => (
                      <li key={index}>{artifact}</li>
                    ))}
                  </ul>
                </div>
              )}
              {extractedInfo.people && extractedInfo.people.length > 0 && (
                <div className="mb-3">
                  <h5>People:</h5>
                  <ul>
                    {extractedInfo.people.map((person, index) => (
                      <li key={index}>{person}</li>
                    ))}
                  </ul>
                </div>
              )}
              {extractedInfo.keywords && extractedInfo.keywords.length > 0 && (
                <div className="mb-3">
                  <h5>Key Findings:</h5>
                  <ul>
                    {extractedInfo.keywords.map((keyword, index) => (
                      <li key={index}>{keyword}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default InformationExtractor;