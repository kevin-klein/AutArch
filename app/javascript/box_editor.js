import React from 'react';
import ReactDOM from 'react-dom';
import htm from 'htm';
const html = htm.bind(React.createElement);

function Box({onPointChange, active, figure: { id, x1, y1, x2, y2, width, height, type_name}}) {
  let color = 'black';

  if(active === id) {
    color = "red";
  }

  function onPointClick(evt, point) {
    console.log(evt);
  }

  return html`
    <text
      x=${x1}
      y=${y1}
      >
        ${type_name}
    </text>
    <rect
      fill='none'
      stroke=${color}
      stroke-width=2
      x=${x1}
      y=${y1}
      width=${width}
      height=${height}
    />

  <circle onMouseDown=${(evt) => onPointClick(evt) } class="moveable-point" r=4 cx=${x1} cy=${y1} stroke="black" />
  <circle class="moveable-point" r=4 cx=${x2} cy=${y2} stroke="black" />
  `;
}

function BoxEditor(props) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [boxes, setBoxes] = React.useState(props.boxes);
  const [arrowAngle, setArrowAngle] = React.useState(props.angle);
  const [showFigures, setShowFigures] = React.useState(true);

  const [currentEditBox, setCurrentEditBox] = React.useState(null);

  function onPointClick(event) {

  }

  const angle = Math.abs(360 - arrowAngle);

  function currentEditBoxActiveClass(box) {
    if(box.id === currentEditBox) {
      return ' active';
    }
  }

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

        <div class="form-check">
          <input type="checkbox" checked=${showFigures} onChange=${() => setShowFigures(!showFigures)} />
          <label class="form-check-label">
            show figures?
          </label>
        </div>
        <svg width="512" height="724" xmlns="http://www.w3.org/2000/svg">
          <image width="512" height="724" href=${props.image} />

          ${showFigures && boxes.map(figure => html`<${Box} active=${currentEditBox} figure=${figure} />`)}
        </svg>
      </div>
      <div class='col-md-6'>
        <div class="input-group mb-3">
          <span class="input-group-text">Arrow Angle</span>
          <input onChange=${(evt) => setArrowAngle(evt.target.value || 0)} value=${arrowAngle} type="text" class="form-control" placeholder="Username" aria-label="Username" aria-describedby="basic-addon1" />
        </div>

        <div class="input-group mb-3">
          <select class="form-select" aria-label="Default select example">
            <option selected>Please select site</option>
            <option value="1">One</option>
            <option value="2">Two</option>
            <option value="3">Three</option>
          </select>
        </div>

        <ul class="list-group">
          ${boxes.map(figure => html`<a href="#" onClick=${(evt) => {evt.preventDefault(); setCurrentEditBox(figure.id); } } class="list-group-item list-group-item-action ${currentEditBoxActiveClass(figure)}">${figure.type_name}</a>`)}
        </ul>
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
