import React from 'react';
import ReactDOM from 'react-dom';
import SummarySourcesModal from '../components/SummarySourcesModal';

// Function to initialize the SummarySourcesModal component
const initializeSummarySourcesModal = () => {
  // Find all elements with data-react-component="SummarySourcesModal"
  const elements = document.querySelectorAll('[data-react-component="SummarySourcesModal"]');
  
  elements.forEach(element => {
    // Get the figure ID and type from data attributes
    const figureId = element.dataset.figureId;
    const figureType = element.dataset.figureType;
    
    // Create a container for the modal
    const container = document.createElement('div');
    container.id = `summarySourcesModalContainer-${figureId}`;
    
    // Insert the container after the button
    element.parentNode.insertBefore(container, element.nextSibling);
    
    // Add click event listener to the button
    element.addEventListener('click', (event) => {
      event.preventDefault();
      
      // Create and render the modal
      ReactDOM.render(
        <SummarySourcesModal 
          show={true} 
          onHide={() => {
            // Unmount the component when modal is closed
            ReactDOM.unmountComponentAtNode(container);
          }}
          figureId={figureId}
          figureType={figureType}
        />, 
        container
      );
    });
  });
};

// Initialize when the DOM is loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeSummarySourcesModal);
} else {
  initializeSummarySourcesModal();
}