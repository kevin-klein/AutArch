import React from 'react';
import ReactDOM from 'react-dom';
import htm from 'htm';
const html = htm.bind(React.createElement);

function Box({figure: { creating, x1, y1, width, height, type_name}}) {
  const color = null;

  return html`
    <text x=${x1} y=${y1}>${type_name}</text>
    <rect fill='none' stroke='black' x=${x1} y=${y1} width=${width} height=${height}>
    </rect>
  `;
}

function BoxEditor(props) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [boxes, setBoxes] = React.useState(props.boxes);

  function onSvgClick(event) {
    setBoxes([...boxes, { x1: event.x, y1: event.y, creating: true, }])
    setIsCreatingBox(true);
  }

  return html`
    <div class='row'>
      <div class='col-md-12'>

      </div>

      <div class='col-md-12'>
        <svg width="512" height="724" xmlns="http://www.w3.org/2000/svg" onClick=${onSvgClick}>
          <image width="512" height="724" href=${props.image} />

          ${boxes.map(figure => html`<${Box} figure=${figure} />`)}
        </svg>
      </div>
    </div>
  `;
}

document.addEventListener('DOMContentLoaded', () => {
  const boxElement = document.getElementById('box-editor');

  if(boxElement !== null) {
    const figures = JSON.parse(boxElement.dataset.figures);
    const image = boxElement.dataset.image;

    ReactDOM.render(
      React.createElement(BoxEditor, {boxes: figures, image: image}, null),
      boxElement,
    );
  }
})
