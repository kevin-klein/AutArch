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
  const [arrowAngle, setArrowAngle] = React.useState(props.angle);

  function onSvgClick(event) {
    setBoxes([...boxes, { x1: event.x, y1: event.y, creating: true, }])
    setIsCreatingBox(true);
  }

  const angle = Math.abs(360 - arrowAngle);

  return html`
    <div class='row'>
      <div class='col-md-6'>
        <svg width="512" height="200">
          <g stroke="blue" shape-rendering="geometricPrecision" transform=${"rotate(" + angle + " 100 85)"}>
            <line x1="100" y1="20" x2="100" y2="150" />
            <line x1="100" x2="110" y1="20" y2="40" />
            <line x1="100" x2="90" y1="20" y2="40" />
          </g>
        </svg>
        <svg width="512" height="724" xmlns="http://www.w3.org/2000/svg" onClick=${onSvgClick}>
          <image width="512" height="724" href=${props.image} />

          ${boxes.map(figure => html`<${Box} figure=${figure} />`)}
        </svg>
      </div>
      <div class='col-md-6'>
        <div class="input-group mb-3">
          <span class="input-group-text">Arrow Angle</span>
          <input onChange=${(evt) => setArrowAngle(evt.target.value || 0)} value=${arrowAngle} type="text" class="form-control" placeholder="Username" aria-label="Username" aria-describedby="basic-addon1" />
        </div>
      </div>

    </div>
  `;
}

document.addEventListener('DOMContentLoaded', () => {
  const boxElement = document.getElementById('box-editor');

  if(boxElement !== null) {
    const figures = JSON.parse(boxElement.dataset.figures);
    const image = boxElement.dataset.image;
    const angle = parseFloat(boxElement.dataset.arrowAngle);

    ReactDOM.render(
      React.createElement(BoxEditor, {angle:angle, boxes: figures, image: image}, null),
      boxElement,
    );
  }
})
