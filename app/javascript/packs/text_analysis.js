import React from 'react';
import ReactDOM from 'react-dom';
import TextAnalysis from '../components/TextAnalysis';

// Initialize TextAnalysis component on pages where it's needed
if (document.getElementById('text-analysis-container')) {
  const container = document.getElementById('text-analysis-container');
  
  // Render the component
  ReactDOM.render(<TextAnalysis />, container);
}