import React, { useState } from 'react';
import TextSummarizer from './TextSummarizer';
import InformationExtractor from './InformationExtractor';

const TextAnalysis = () => {
  const [activeTab, setActiveTab] = useState('summarize');
  
  return (
    <div className="text-analysis">
      <h2>Text Analysis</h2>
      <ul className="nav nav-tabs mb-3">
        <li className="nav-item">
          <button 
            className={`nav-link ${activeTab === 'summarize' ? 'active' : ''}`} 
            onClick={() => setActiveTab('summarize')}
          >
            Summarize Text
          </button>
        </li>
        <li className="nav-item">
          <button 
            className={`nav-link ${activeTab === 'extract' ? 'active' : ''}`} 
            onClick={() => setActiveTab('extract')}
          >
            Extract Information
          </button>
        </li>
      </ul>
      
      <div className="tab-content">
        {activeTab === 'summarize' && <TextSummarizer />}
        {activeTab === 'extract' && <InformationExtractor />}
      </div>
    </div>
  );
};

export default TextAnalysis;