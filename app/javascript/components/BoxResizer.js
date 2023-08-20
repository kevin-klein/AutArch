import React from 'react';
import { Wizard, useWizard } from 'react-use-wizard';
import Select from 'react-select';
import {useFigureStore} from './store';

function rotatePoint(x, y, figure) {
  const centerX = (figure.x2 + figure.x1) / 2;
  const centerY = (figure.y2 + figure.y1) / 2;
  let newX = (x - centerX) * Math.cos(-figure.bounding_box_angle) - (y - centerY) * Math.sin(-figure.bounding_box_angle);
  let newY = (x - centerX) * Math.sin(-figure.bounding_box_angle) + (y - centerY) * Math.cos(-figure.bounding_box_angle);
  newX = newX + centerX;
  newY = newY + centerY;

  return {
    x: newX,
    y: newY
  }
}

function ManualBoundingBox({figure, color, onDraggingStart}) {
  function onMouseDown(figure) {
    return function(evt) {
      evt.preventDefault();
      onDraggingStart(evt, figure);
    };
  }

  return (<React.Fragment>
    <rect
      fill='none'
      stroke={color}
      strokeWidth="3"
      x={figure.x1}
      y={figure.y1}
      width={figure.x2 - figure.x1}
      height={figure.y2 - figure.y1}
      transform={`rotate(${figure.bounding_box_angle} ${figure.bounding_box_center_x}, ${figure.bounding_box_center_y}`}
    />
    <circle
      className="moveable-point"
      r='10'
      cx={figure.bounding_box_center_x}
      cy={figure.bounding_box_center_y}
      fill="green"
    />
    <circle
      onMouseDown={onMouseDown({ figure: figure, point: 1 })}
      className="moveable-point"
      r='10'
      cx={figure.bounding_box_center_x - figure.bounding_box_width / 2}
      cy={figure.bounding_box_center_y - figure.bounding_box_height / 2}
      stroke="black"
      transform={`rotate(${figure.bounding_box_angle} ${(figure.x2 + figure.x1) / 2}, ${(figure.y2 + figure.y1) / 2})`}
    />
    <circle
      onMouseDown={onMouseDown({ figure: figure, point: 2 })}
      className="moveable-point"
      r='10'
      cx={figure.bounding_box_center_x + figure.bounding_box_width / 2}
      cy={figure.bounding_box_center_y + figure.bounding_box_height / 2}
      stroke="black"
      transform={`rotate(${figure.bounding_box_angle} ${(figure.x2 + figure.x1) / 2}, ${(figure.y2 + figure.y1) / 2})`}
    />
  </React.Fragment>);
}

export function Box({onDraggingStart, active, figure}) {
  const { id, x1, y1, x2, y2, type } = figure;

  let color = 'black';
  if(active === id) {
    color = '#F44336';
  }

  if(figure.manual_bounding_box) {
    return <ManualBoundingBox onDraggingStart={onDraggingStart} figure={figure} color={color} />;
  }

  function onMouseDown(figure) {
    return function(evt) {
      console.log(figure);
      evt.preventDefault();
      onDraggingStart(evt, figure);
    };
  }

  return (<React.Fragment>
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="7"
        refX="0" refY="3.5" orient="auto">
        <polygon points="0 0, 10 3.5, 0 7" />
      </marker>
    </defs>

    {(type === 'Spine' || type === 'CrossSectionArrow') &&
      <line
        fill='none'
        stroke={color}
        strokeWidth="2"
        x1={x1}
        y1={y1}
        x2={x2}
        y2={y2}

        markerEnd="url(#arrowhead)" />
    }

    {type !== 'Spine' && <rect
      fill='none'
      stroke={color}
      strokeWidth="3"
      x={x1}
      y={y1}
      width={x2 - x1}
      height={y2 - y1}
    />}

    <circle
      onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 1 })}
      className="moveable-point"
      r='10'
      cx={x1}
      cy={y1}
      stroke="black"
    />
    <circle
      onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 2 })}
      className="moveable-point"
      r='10'
      cx={x2}
      cy={y2}
      stroke="black"
    />
  </React.Fragment>)
  ;
}

function NewFigureDialog({ closeDialog, addFigure }) {
  const [type, setType] = React.useState('Spine');

  return (<div className="modal d-block" aria-hidden="false">
    <div className="modal-dialog">
      <div className="modal-content">
        <div className="modal-header">
          <h1 className="modal-title fs-5" id="exampleModalLabel">New Figure</h1>
          <button type="button" onClick={closeDialog} className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
          <form>
            <div className="input-group mb-3">
              <select value={type} onChange={evt => setType(evt.target.value)} className="form-select" aria-label="Default select example">
                <option value="Spine">Spine</option>
                <option value="SkeletonFigure">Skeleton</option>
                <option value="Scale">Scale</option>
                <option value="GraveCrossSection">Grave Cross Section</option>
                <option value="Arrow">Arrow</option>
              </select>
            </div>
          </form>
        </div>
        <div className="modal-footer">
          <button type="button" onClick={closeDialog} className="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" onClick={() => { addFigure(type); closeDialog(); } } className="btn btn-primary">Create</button>
        </div>
      </div>
    </div>
  </div>);
}

function Contour({figure, active}) {
  const points = [...figure.contour, figure.contour[0]].map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`).join(' ');
  return (
    <polyline
      points={points}
      fill={ figure.id === active ? '#F4433699' : '#3F51B5' }
      stroke={ '#3F51B5' }
      strokeWidth={5}
    />
  );
}

export default ({next_url, grave, sites, image, page}) => {
  const {figures, updateFigure, setFigures, addFigure, removeFigure} = useFigureStore();

  const [rendering, setRendering] = React.useState('boxes');
  const [draggingState, setDraggingState] = React.useState(null);
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false);
  const canvasRef = React.useRef(null);
  const [currentEditBox, setCurrentEditBox] = React.useState(grave.figures.filter((f) => f.type == 'Grave')[0]?.id);
  // const graveFigure = figures.filter(figure => figure.id === grave.id)[0];

  React.useEffect(() => {
    setFigures(grave.figures);
  }, []);

  const token =
      document.querySelector('[name=csrf-token]').content;

  function currentEditBoxActiveClass(figure) {
    if(figure.id === currentEditBox) {
      return ' active';
    }
  }

  function createNewFigure() {
    setCreatingNewFigure(true);
  }

  async function removeEditBox(id) {
    const response = await fetch(`/figures/${id}.json`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json',
      }
    });
    if (response.ok) {
      removeFigure(figures[id]);
    } else {
      return Promise.reject(response);
    }
  }

  function onChangeFigure(id, figure) {
    setFigures(Object.values(figures).map((currentFigure) => {
      if(currentFigure.id === figure.id) {
        return figure;
      }
      else {
        return currentFigure;
      }
    }));
  }

  function setManualBoundingBox(figure, checked) {
    if(checked && figure.bounding_box_angle === null) {
      const centerX = (figure.x1 + figure.x2) / 2;
      const centerY = (figure.y1 + figure.y2) / 2;
      const angle = 0;
      const width = figure.x2 - figure.x1;
      const height = figure.y2 - figure.y1;
      onChangeFigure(figure.id, {
        ...figure,
        manual_bounding_box: checked,
        bounding_box_center_x: centerX,
        bounding_box_center_y: centerY,
        bounding_box_angle: angle,
        bounding_box_width: width,
        bounding_box_height: height
      });
    }
    else {
      onChangeFigure(figure.id, { ...figure, manual_bounding_box: checked });
    }
  }

  function onDraggingStart(evt, data) {
    const figure = data.figure;
    setCurrentEditBox(figure.id);
    let svgPoint = canvasRef.current.createSVGPoint();
    svgPoint.x = evt.clientX;
    svgPoint.y = evt.clientY;
    svgPoint = svgPoint.matrixTransform(canvasRef.current.getScreenCTM().inverse());

    setDraggingState({
      point: svgPoint,
      x1: svgPoint.x - figure.x1,
      y1: svgPoint.y - figure.y1,
      x2: svgPoint.x - figure.x2,
      y2: svgPoint.y - figure.y2,
      data: data,
    });
  }

  async function createFigure(type) {
    const grave = Object.values(figures).filter(figure => figure.type === 'Grave')[0];

    let newFigure = null;
    if(grave !== undefined) {
      if(type === 'Spine') {
        const graveWidth = grave.x2 - grave.x1;
        const graveHeight = grave.y2 - grave.y1;
        const x1 = grave.x1 + graveWidth * 0.5;
        const x2 = grave.x1 + graveWidth * 0.5;

        const y1 = grave.y1 + graveHeight * 0.6;
        const y2 = grave.y1 + graveHeight * 0.4;

        newFigure = { ...grave, page_id: page.id, y1: y1, y2: y2, x1: x1, x2: x2, type: type };
      }
      else {
        const graveWidth = grave.x2 - grave.x1;
        const graveHeight = grave.y2 - grave.y1;
        const x1 = grave.x1 + graveWidth * 0.3;
        const x2 = grave.x1 + graveWidth * 0.6;

        const y1 = grave.y1 + graveHeight * 0.4;
        const y2 = grave.y1 + graveHeight * 0.6;

        newFigure = { ...grave, page_id: page.id, y1: y1, y2: y2, x1: x1, x2: x2, type: type };
      }
    }
    else{
      newFigure = { type: type, page_id: page.id, x1: 0, y1: 0, x2: 100, y2: 100 };
    }

    const response = await fetch('/figures.json', {
      method: 'POST',
      body: JSON.stringify({grave_id: grave.id, figure: {
        x1: newFigure.x1,
        x2: newFigure.x2,
        y1: newFigure.y1,
        y2: newFigure.y2,
        page_id: newFigure.page_id,
        type: newFigure.type,
        parent_id: grave.id,
      }}),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json',
      }
    });
    if (response.ok) {
      newFigure = await response.json();
      addFigure({...newFigure, type: type});
      setCurrentEditBox(newFigure.id);
    } else {
      return Promise.reject(response);
    }
  }

  function onSiteChange(evt) {
    setSite(evt.value);
  }

  function onDrag(evt) {
    if(draggingState !== null) {
      const figure = figures[draggingState.data.figure.id];

      draggingState.point.x = evt.clientX;
      draggingState.point.y = evt.clientY;
      const cursor = draggingState.point.matrixTransform(canvasRef.current.getScreenCTM().inverse());

      if(evt.ctrlKey) {
        const x1 = cursor.x - draggingState.x1;
        const y1 = cursor.y - draggingState.y1;

        const x2 = cursor.x - draggingState.x2;
        const y2 = cursor.y - draggingState.y2;
        updateFigure({ ...figure, x1: x1, y1: y1, x2: x2, y2: y2 });
      }
      else {
        if(draggingState.data.point === 1) {
          let x = cursor.x - draggingState.x1;
          let y = cursor.y - draggingState.y1;

          if(figure.bounding_box_angle !== null) {
            const result = rotatePoint(x, y, figure);
            x = result.x;
            y = result.y;
          }
          updateFigure({ ...figure, x1: x, y1: y });
        }
        else {
          let x = cursor.x - draggingState.x2;
          let y = cursor.y - draggingState.y2;

          if(figure.bounding_box_angle !== null) {
            const result = rotatePoint(x, y, figure);
            x = result.x;
            y = result.y;
          }
          updateFigure({ ...figure, x2: x, y2: y });
        }
      }
    }
  }

  const validations = ['Scale', 'Arrow', 'Spine', 'SkeletonFigure', 'GraveCrossSection'].map((item) => {
    const matchingFigure = Object.values(figures).filter(fig => fig.type === item)[0];
    if(matchingFigure === undefined) {
      if(item === 'SkeletonFigure' || item === 'Spine') {
        return (
          <li className="list-group-item alert-warning">{item} is missing</li>
        );
      }
      else {
        return (
          <li className="list-group-item alert-danger">{item} is missing</li>
        );
      }
    }
  });

  return (<React.Fragment>
    {creatingNewFigure && <NewFigureDialog addFigure={createFigure} closeDialog={() => setCreatingNewFigure(false)} />}
    <div className='row'>
      <div className='col-md-8 card'>
        <div className="form-check">
          <select value={rendering} onChange={evt => setRendering(evt.target.value)} className="form-select" aria-label="Default select example">
            <option value='boxes'>Show Bounding Boxes</option>
            <option value='contours'>Show Contours</option>
            <option value='nothing'>Show Nothing</option>
          </select>
        </div>
        <svg
          ref={canvasRef}
          onMouseMove={onDrag}
          onMouseUp={() => { setDraggingState(null); }}
          onMouseLeave={() => { setDraggingState(null); }}
          viewBox={`0 0 ${image.width} ${image.height}`}
          preserveAspectRatio="xMidYMid meet"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image width={image.width} height={image.height} href={image.href} />
          {rendering === 'boxes' && Object.values(figures).map(figure => <Box canvas={canvasRef} key={figure.id} onDraggingStart={onDraggingStart} active={currentEditBox} figure={figure} />)}
          {rendering === 'contours' && Object.values(figures).filter(figure => ['Grave', 'Arrow', 'Scale'].indexOf(figure.type) !== -1 ).map(figure => <Contour key={figure.id} active={currentEditBox} figure={figure} />)}
        </svg>
      </div>

      <div className='col-md-4'>
        <div style={{position: 'sticky', top: 60}} className="card">
          <div className="card-body">
            <h5 className="card-title">Edit Grave</h5>
            <div className="card-text">
              <ul className="list-group">
                {Object.values(figures).map(figure =>
                  <React.Fragment key={figure.id}>
                    <div
                      onClick={() => { setCurrentEditBox(figure.id); } }
                      className={`list-group-item list-group-item-action d-flex justify-content-between align-items-start ${currentEditBoxActiveClass(figure)}`}
                    >
                      <div className="ms-2 me-auto">
                        <div className="fw-bold">{figure.type}</div>
                      </div>
                      <div
                        onClick={() => { removeEditBox(figure.id); } }
                        className="btn btn-primary badge bg-primary rounded-pill"
                        role="button" data-bs-toggle="button">
                          X
                      </div>
                    </div>
                    {currentEditBox === figure.id && figure.type === 'Grave' &&
                      <div className="row mb-3 mt-3">
                        <div className="form-check ms-3">
                          <input
                            className="form-check-input"
                            type="checkbox"
                            value={figure.manual_bounding_box}
                            onChange={(evt) => { setManualBoundingBox(figure, evt.target.checked) }}
                          />
                          <label className="form-check-label">
                            manually align bounding box
                          </label>
                        </div>

                        {figure.manual_bounding_box && <React.Fragment>
                          <label className="form-label ms-2" htmlFor="arrow-range-input">Angle: {figure.bounding_box_angle}°</label>
                          <div className="range">
                            <input id='arrow-range-input' type="range" className="form-range" min="0" max="360" onChange={(evt) => onChangeFigure(figure.id, { ...figure, bounding_box_angle: evt.target.value })} value={figure.bounding_box_angle} />
                          </div>

                          <label className="form-label ms-2" htmlFor="arrow-range-input">Width: {figure.bounding_box_width}</label>
                          <div className="range">
                            <input id='arrow-range-input' type="range" className="form-range" min="0" max={image.width} onChange={(evt) => onChangeFigure(figure.id, { ...figure, bounding_box_width: evt.target.value })} value={figure.bounding_box_width} />
                          </div>

                          <label className="form-label ms-2" htmlFor="arrow-range-input">Height: {figure.bounding_box_height}</label>
                          <div className="range">
                            <input id='arrow-range-input' type="range" className="form-range" min="0" max={image.height} onChange={(evt) => onChangeFigure(figure.id, { ...figure, bounding_box_height: evt.target.value })} value={figure.bounding_box_height} />
                          </div>
                        </React.Fragment>}

                      </div>}
                    {currentEditBox === figure.id && figure.type === 'SkeletonFigure' &&
                      <div className="row mb-3 mt-3">
                        <label className="col-sm-2 col-form-label">Position</label>
                        <div className="col-sm-10">
                          <select
                            value={figure.deposition_type}
                            className="form-select"
                            aria-label="Default select example"
                            onChange={(evt) => { onChangeFigure(figure.id, { ...figure, deposition_type: evt.target.value }) }}
                          >
                            <option value="unknown">Unknown</option>
                            <option value="back">Back</option>
                            <option value="side">Side</option>
                          </select>
                        </div>
                      </div>}
                  </React.Fragment>
                )}

                <a
                  href="#"
                  onClick={(evt) => {evt.preventDefault(); createNewFigure(); } }
                  className="list-group-item list-group-item-action d-flex justify-content-between align-items-start"
                >
                  <div className="ms-2 me-auto">
                    <div className="fw-bold">New Figure</div>
                  </div>
                </a>
              </ul>
            </div>
            <form action={next_url} method='post'>
              <input type="hidden" name="_method" value="patch" />
              <input type="hidden" name="authenticity_token" value={token} />
              {Object.values(figures).map(figure => {
                const id = figure.id;
                return (
                  <React.Fragment key={figure.id}>
                    <input type='hidden' name={`figures[${id}][x1]`} value={figure.x1} />
                    <input type='hidden' name={`figures[${id}][x2]`} value={figure.x2} />
                    <input type='hidden' name={`figures[${id}][y1]`} value={figure.y1} />
                    <input type='hidden' name={`figures[${id}][y2]`} value={figure.y2} />
                    <input type='hidden' name={`figures[${id}][verified]`} value={figure.verified} />
                    <input type='hidden' name={`figures[${id}][disturbed]`} value={figure.disturbed} />
                    <input type='hidden' name={`figures[${id}][deposition_type]`} value={figure.deposition_type} />
                    <input type='hidden' name={`figures[${id}][publication_id]`} value={figure.publication_id} />
                    <input type='hidden' name={`figures[${id}][text]`} value={figure.text} />
                    <input type='hidden' name={`figures[${id}][angle]`} value={figure.angle} />
                  </React.Fragment>
                );
              })}

              <input value='Next' type='submit' className="btn btn-primary card-link mt-1" />
            </form>

            <ul className="list-group mt-3">
              {validations}
            </ul>

          </div>
        </div>
      </div>

    </div>
  </React.Fragment>);
}
