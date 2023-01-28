/* eslint-disable react/prop-types */
import React from 'react';
import Select from 'react-select';

const genUUID = () =>
  ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
    (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
  );

function Box({onDraggingStart, active, figure: { id, x1, y1, x2, y2, type}}) {
  let color = 'black';
  if(active === id) {
    color = 'red';
  }

  function onMouseDown(figure) {
    return function(evt) {
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
      strokeWidth="2"
      x={x1}
      y={y1}
      width={x2 - x1}
      height={y2 - y1}
    />}

    <circle
      onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 1 })}
      className="moveable-point"
      r='4'
      cx={x1}
      cy={y1}
      stroke="black"
    />
    <circle
      onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 2 })}
      className="moveable-point"
      r='4'
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
                <option value="Skeleton">Skeleton</option>
                <option value="Skull">Skull</option>
                <option value="Scale">Scale</option>
                <option value="GraveCrossSection">Grave Cross Section</option>
                <option value="Arrow">Arrow</option>
                <option value="Good">Good</option>
                <option value="CrossSectionArrow">Cross Section Arrow</option>
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

export default function BoxEditor({grave, sites, image, page}) {
  const [figures, setFigures] = React.useState(grave.figures);
  const [arrowAngle, setArrowAngle] = React.useState(grave.figures.filter(figure => figure.type === 'Arrow')[0]?.angle || 0);
  const [showFigures, setShowFigures] = React.useState(true);
  const [draggingState, setDraggingState] = React.useState(null);
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false);
  const [site, setSite] = React.useState(grave.site_id);
  const canvasRef = React.useRef(null);
  const [currentEditBox, setCurrentEditBox] = React.useState(grave.figures.filter((f) => f.type == 'Grave')[0]?.id);

  const token =
      document.querySelector('[name=csrf-token]').content;

  const angle = Math.abs(360 - arrowAngle);

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
      setFigures(figures.filter((figure) => figure.id !== id));
    } else {
      return Promise.reject(response);
    }
  }

  function onDraggingStart(evt, data) {
    const figure = data.figure;
    setCurrentEditBox(figure.id);
    let svgPoint = canvasRef.current.createSVGPoint();
    svgPoint.x = evt.clientX;
    svgPoint.y = evt.clientY;
    svgPoint = svgPoint.matrixTransform(canvasRef.current.getScreenCTM().inverse());

    let x = 0;
    let y = 0;
    if(data.point === 1) {
      x = figure.x1;
      y = figure.y1;
    }
    else {
      x = figure.x2;
      y = figure.y2;
    }

    setDraggingState({
      point: svgPoint,
      x: svgPoint.x - x,
      y: svgPoint.y - y,
      data: data,
    });
  }

  async function addFigure(type) {
    const grave = figures.filter(figure => figure.type === 'Grave')[0];

    let newFigure = null;
    if(grave !== undefined) {
      const graveWidth = grave.x2 - grave.x1;
      const graveHeight = grave.y2 - grave.y1;
      const x1 = grave.x1 + graveWidth * 0.3;
      const x2 = grave.x1 + graveWidth * 0.6;

      const y1 = grave.y1 + graveHeight * 0.4;
      const y2 = grave.y1 + graveHeight * 0.6;

      newFigure = { ...grave, page_id: page.id, y1: y1, y2: y2, x1: x1, x2: x2, type: type };
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
      setFigures([...figures, {...newFigure, type: type}]);
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
      setFigures(figures.map((figure) => {
        if(figure.id === draggingState.data.figure.id) {
          draggingState.point.x = evt.clientX;
          draggingState.point.y = evt.clientY;
          const cursor = draggingState.point.matrixTransform(canvasRef.current.getScreenCTM().inverse());

          const x = cursor.x - draggingState.x;
          const y = cursor.y - draggingState.y;

          if(draggingState.data.point === 1) {
            return { ...figure, x1: x, y1: y };
          }
          else {
            return { ...figure, x2: x, y2: y };
          }
        }
        return figure;
      }));
    }

  }

  const siteOptions = sites.map((site) => { return { value: site.id, label: site.name }; });
  const siteValue = siteOptions.filter((option) => option.value === site )[0];

  let arrowView = null;
  const arrow = grave.figures.filter((f) => f.type == 'Arrow')[0];
  if(arrow) {
    const arrowCenterX = (arrow.x1 + arrow.x2) / 2;
    const arrowCenterY = (arrow.y1 + arrow.y2) / 2;

    arrowView = (<svg width="512" height="200" viewBox={`${arrow.x1} ${arrow.y1} ${arrow.x2 - arrow.x1} ${arrow.y2 - arrow.y1}`}>
      <image width={image.width} height={image.height} href={image.href} />
      <g transform={`rotate(${angle} ${arrowCenterX} ${arrowCenterY}) translate(${arrowCenterX - 100} ${arrowCenterY - 80})`} stroke="blue" shapeRendering="geometricPrecision">
        <line x1="100" y1="20" x2="100" y2="150" />
        <line x1="100" x2="110" y1="20" y2="40" />
        <line x1="100" x2="90" y1="20" y2="40" />
      </g>
    </svg>);
  }

  return (<React.StrictMode>
    {creatingNewFigure && <NewFigureDialog addFigure={addFigure} closeDialog={() => setCreatingNewFigure(false)} />}
    <div className='row'>
      <div className='col-md-8'>
        {arrowView}

        <div className="form-check">
          <input type="checkbox" checked={showFigures} onChange={() => setShowFigures(!showFigures)} />
          <label className="form-check-label">
            show figures?
          </label>
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
          {showFigures && figures.map(figure => <Box canvas={canvasRef} key={figure.id} onDraggingStart={onDraggingStart} active={currentEditBox} figure={figure} />)}
        </svg>
      </div>

      <div className='col-md-4'>
        <div style={{position: 'sticky', top: 60}} className="card">
          <div className="card-body">
            <h5 className="card-title">Edit Grave</h5>
            <span className="card-text">
              <div className="input-group mb-3">
                <span className="input-group-text">Arrow Angle: {arrowAngle} degree</span>
                <button className='btn btn-info' onClick={() => setArrowAngle((arrowAngle + 180) % 360)}>Flip Angle</button>
                <input type="range" className="form-range" min="0" max="360" onChange={(evt) => setArrowAngle(evt.target.value || 0)} value={arrowAngle} />
              </div>

              <div className="input-group mb-3">
                <Select value={siteValue} onChange={onSiteChange} className="form-select" options={siteOptions} />
              </div>

              <ul className="list-group">
                {figures.map(figure =>
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
                    {currentEditBox === figure.id && figure.type === 'SkeletonFigure' &&
                      <>
                        <Select className='form-select' options={[{value: 0, label: 'supine position' }]} />
                        <a href={`#/skeletons/${figure.id}`}>Edit</a>
                      </>}
                    {currentEditBox === figure.id && figure.type === 'Grave' &&
                    <>
                      <div className="row mb-3 mt-3">
                        <label className="col-sm-2 col-form-label">Grave ID</label>
                        <div className="col-sm-10">
                          <input type="email" className="form-control" />
                        </div>
                      </div>
                    </>}
                  </React.Fragment>
                )}

                <a
                  href="#"
                  onClick={(evt) => {evt.preventDefault(); createNewFigure(); } }
                  className="list-group-item list-group-item-action d-flex justify-content-between align-items-start"
                >
                  <div className="ms-2 me-auto">
                    <div className="fw-bold">New figure</div>
                  </div>
                </a>
              </ul>
            </span>
            <form action={`/graves/${grave.id}`} method='post'>
              <input type="hidden" name="_method" value="patch" />
              <input type="hidden" name="authenticity_token" value={token} />
              {figures.map(figure => {
                const id = figure.id;
                if(figure.type === 'Arrow') {
                  figure.angle = arrowAngle;
                }
                return (
                  <React.Fragment key={figure.id}>
                    <input type='hidden' name={`figures[${id}][x1]`} value={figure.x1} />
                    <input type='hidden' name={`figures[${id}][x2]`} value={figure.x2} />
                    <input type='hidden' name={`figures[${id}][y1]`} value={figure.y1} />
                    <input type='hidden' name={`figures[${id}][y2]`} value={figure.y2} />
                    {figure.angle &&
                     <input type='hidden' name={`figures[${id}][angle]`} value={figure.angle} />
                    }
                  </React.Fragment>
                );
              })}

              <input value='Save' type='submit' className="btn btn-primary card-link" />
            </form>

          </div>
        </div>
      </div>

    </div>
  </React.StrictMode>);
}
