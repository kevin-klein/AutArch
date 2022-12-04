import React from 'react';
import ReactDOM from 'react-dom';
import htm from 'htm';
const html = htm.bind(React.createElement);

const genUUID = () =>
  ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
    (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
  );

function Box({setDraggingPoint, active, figure: { id, x1, y1, x2, y2, width, height, type_name}}) {
  let color = 'black';

  if(active === id) {
    color = "red";
  }

  function onPointClick(evt, point) {
    evt.preventDefault();
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
      width=${x2 - x1}
      height=${y2 - y1}
    />

  <circle
    onMouseDown=${(evt) => { evt.preventDefault(); setDraggingPoint({ figure: { id, x1, x2, y1, y2 }, point: 1 }); } }
    class="moveable-point"
    r=4
    cx=${x1}
    cy=${y1}
    stroke="black"
  />
  <circle
    onMouseDown=${(evt) => { evt.preventDefault(); setDraggingPoint({ figure: { id, x1, x2, y1, y2 }, point: 2 }); } }
    class="moveable-point"
    r=4
    cx=${x2}
    cy=${y2}
    stroke="black"
  />
  `;
}

function NewFigureDialog({ closeDialog, addFigure }) {
  const [type, setType] = React.useState(null);

  return html`<div class="modal d-block" aria-hidden="false">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h1 class="modal-title fs-5" id="exampleModalLabel">New Figure</h1>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <form>
            <div class="input-group mb-3">
              <select onChange=${evt => setType(evt.target.value)} class="form-select" aria-label="Default select example">
                <option selected>Please select type</option>
                <option value="skeleton">Skeleton</option>
                <option value="skull">Skull</option>
                <option value="scale">Scale</option>
                <option value="grave_cross_section">Grave Cross Section</option>
                <option value="arrow">Arrow</option>
                <option value="good">Good</option>
                <option value="spine">Spine</option>
              </select>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" onClick=${() => { addFigure(type); closeDialog(); } } class="btn btn-primary">Send message</button>
        </div>
      </div>
    </div>
  </div>
  `;
}

function BoxEditor(props) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [boxes, setBoxes] = React.useState(props.boxes);
  const [arrowAngle, setArrowAngle] = React.useState(props.angle);
  const [showFigures, setShowFigures] = React.useState(true);
  const [draggingPoint, setDraggingPoint] = React.useState(null);
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false);

  const [currentEditBox, setCurrentEditBox] = React.useState(null);

  const angle = Math.abs(360 - arrowAngle);

  function currentEditBoxActiveClass(box) {
    if(box.id === currentEditBox) {
      return ' active';
    }
  }

  function createNewFigure() {
    setCreatingNewFigure(true);
  }

  function removeEditBox(id) {
    setBoxes(boxes.filter((box) => box.id !== id));
  }

  function addFigure(type) {
    const grave = boxes.filter(box => box.type_name === 'grave')[0];

    if(grave !== undefined) {
      setBoxes([...boxes, { ...grave, type_name: type, id: genUUID() }]);
    }
    else{
      setBoxes([...boxes, { type_name: type, id: genUUID(), x1: 0, y1: 0, x2: 100, y2: 100 }]);
    }

  }

  function onDrag(evt) {
    // var coord = getMousePosition(evt);
    if(draggingPoint !== null) {
      setBoxes(boxes.map((box) => {
        if(box.id === draggingPoint.figure.id) {
          if(draggingPoint.point === 1) {
            return { ...box, x1: box.x1 + evt.movementX, y1: box.y1 + evt.movementY };
          }
          else {
            return { ...box, x2: box.x2 + evt.movementX, y2: box.y2 + evt.movementY };
          }
        }
        return box;
      }));
    }

  }


  return html`
    ${creatingNewFigure && html`<${NewFigureDialog} addFigure=${addFigure} closeDialog=${() => setCreatingNewFigure(false)} />`}
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
        <svg
          onMouseMove=${onDrag}
          onMouseUp=${(evt) => setDraggingPoint(null)}
          onMouseLeave=${(evt) => setDraggingPoint(null)}
          width="512"
          height="724"
          xmlns="http://www.w3.org/2000/svg"
          >
          <image width="512" height="724" href=${props.image} />
          ${showFigures && boxes.map(figure => html`<${Box} setDraggingPoint=${setDraggingPoint} active=${currentEditBox} figure=${figure} />`)}
        </svg>
      </div>
      <div class='col-md-6'>
        <div class="input-group mb-3">
          <span class="input-group-text">Arrow Angle: ${arrowAngle} degree</span>
          <input type="range" class="form-range" min="0" max="360" onChange=${(evt) => setArrowAngle(evt.target.value || 0)} value=${arrowAngle} />
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
          ${boxes.map(figure =>
            html`
              <a
                href="#"
                onClick=${(evt) => {evt.preventDefault(); setCurrentEditBox(figure.id); } }
                class="list-group-item list-group-item-action d-flex justify-content-between align-items-start ${currentEditBoxActiveClass(figure)}"
                >
                  <div class="ms-2 me-auto">
                    <div class="fw-bold">${figure.type_name}</div>
                  </div>
                  <a href="#" onClick=${(evt) => { evt.preventDefault(); removeEditBox(figure.id); } } class="btn btn-primary badge bg-primary rounded-pill" role="button" data-bs-toggle="button">X</a>
                </a>
              `)}

          <a
            href="#"
            onClick=${(evt) => {evt.preventDefault(); createNewFigure(); } }
            class="list-group-item list-group-item-action d-flex justify-content-between align-items-start"
            >
              <div class="ms-2 me-auto">
                <div class="fw-bold">New figure</div>
              </div>
            </a>
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
