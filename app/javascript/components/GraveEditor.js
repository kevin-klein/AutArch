import React from 'react';
import safeCredentials from './fetchHelper';
import Select from 'react-select'

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
  }

  return (<>
    {type_name === 'spine' && <line
      fill='none'
      stroke={color}
      strokeWidth="2"
      x1={x1}
      y1={y1}
      x2={x2}
      y2={y2}
    />}

    {type_name !== 'spine' && <rect
      fill='none'
      stroke={color}
      strokeWidth="2"
      x={x1}
      y={y1}
      width={x2 - x1}
      height={y2 - y1}
    />}

    <circle
      onMouseDown={(evt) => { evt.preventDefault(); setDraggingPoint({ figure: { id, x1, x2, y1, y2 }, point: 1 }); } }
      className="moveable-point"
      r='4'
      cx={x1}
      cy={y1}
      stroke="black"
    />
    <circle
      onMouseDown={(evt) => { evt.preventDefault(); setDraggingPoint({ figure: { id, x1, x2, y1, y2 }, point: 2 }); } }
      className="moveable-point"
      r='4'
      cx={x2}
      cy={y2}
      stroke="black"
      />
    </>)
    ;
}

function NewFigureDialog({ closeDialog, addFigure }) {
  const [type, setType] = React.useState('default');

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
                <option value="default">Please select type</option>
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
        <div className="modal-footer">
          <button type="button" onClick={closeDialog} className="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" onClick={() => { addFigure(type); closeDialog(); } } className="btn btn-primary">Create</button>
        </div>
      </div>
    </div>
  </div>);
}

export default function BoxEditor(props) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [figures, setFigures] = React.useState(props.figures);
  const [arrowAngle, setArrowAngle] = React.useState(props.arrowAngle || 0);
  const [showFigures, setShowFigures] = React.useState(true);
  const [draggingPoint, setDraggingPoint] = React.useState(null);
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false);
  const [isSaving, setIsSaving] = React.useState(false);
  const [site, setSite] = React.useState(props.grave.site_id);

  const [currentEditBox, setCurrentEditBox] = React.useState(null);

  const angle = Math.abs(360 - arrowAngle);

  function currentEditBoxActiveClass(figure) {
    if(figure.id === currentEditBox) {
      return ' active';
    }
  }

  async function save() {
    setIsSaving(true);
    const response = await fetch('/graves/'+props.id, safeCredentials({
      method: 'put',
      body: JSON.stringify({
        grave: {
          arrowAngle: arrowAngle,
          site_id: site,
          figures: figures.map((figure) => { return { type_name: figure.type_name, id: figure.id, x1: figure.x1, x2: figure.x2, y1: figure.y1, y2: figure.y2 }}),
        }
      })
    }));
    setIsSaving(false);
  }

  function createNewFigure() {
    setCreatingNewFigure(true);
  }

  function removeEditBox(id) {
    setFigures(figures.filter((figure) => figure.id !== id));
  }

  function addFigure(type) {
    const grave = figures.filter(figure => figure.type_name === 'grave')[0];

    if(grave !== undefined) {
      setFigures([...figures, { ...grave, type_name: type, id: genUUID() }]);
    }
    else{
      setFigures([...figures, { type_name: type, id: genUUID(), x1: 0, y1: 0, x2: 100, y2: 100 }]);
    }
  }

  function onSiteChange(evt) {
    setSite(evt.value);
  }

  function onDrag(evt) {
    // var coord = getMousePosition(evt);
    if(draggingPoint !== null) {
      setFigures(figures.map((figure) => {
        if(figure.id === draggingPoint.figure.id) {
          if(draggingPoint.point === 1) {
            return { ...figure, x1: figure.x1 + evt.movementX, y1: figure.y1 + evt.movementY };
          }
          else {
            return { ...figure, x2: figure.x2 + evt.movementX, y2: figure.y2 + evt.movementY };
          }
        }
        return figure;
      }));
    }

  }

  function setDraggingFigure(point) {
    setDraggingPoint(point);
    setCurrentEditBox(point.figure.id);
  }

  const siteOptions = props.sites.map((site) => { return { value: site.id, label: site.name }; });
  const siteValue = siteOptions.filter((option) => option.value === site )[0];

  return (<>
    {creatingNewFigure && <NewFigureDialog addFigure={addFigure} closeDialog={() => setCreatingNewFigure(false)} />}
    <div className='row'>
      <div className='col-md-6'>
        <svg width="512" height="200">
          <g stroke="blue" shapeRendering="geometricPrecision" transform={"rotate(" + angle + " 100 85)"}>
            <line x1="100" y1="20" x2="100" y2="150" />
            <line x1="100" x2="110" y1="20" y2="40" />
            <line x1="100" x2="90" y1="20" y2="40" />
          </g>
        </svg>

        <div className="form-check">
          <input type="checkbox" checked={showFigures} onChange={() => setShowFigures(!showFigures)} />
          <label className="form-check-label">
            show figures?
          </label>
        </div>
        <svg
          onMouseMove={onDrag}
          onMouseUp={(evt) => { setDraggingPoint(null); }}
          onMouseLeave={(evt) => { setDraggingPoint(null); }}
          viewBox="0 0 512 724"
          preserveAspectRatio="xMidYMid meet"
          xmlns="http://www.w3.org/2000/svg"
          >
          <image width="512" height="724" href={props.image} />
          {showFigures && figures.map(figure => <Box key={figure.id} setDraggingPoint={setDraggingFigure} active={currentEditBox} figure={figure} />)}
        </svg>
      </div>
      <div className='col-md-6'>
        <div style={{position: 'sticky', top: 60}} className="card">
          <div className="card-body">
            <h5 className="card-title">Edit Grave</h5>
            <p className="card-text">
              <div className="input-group mb-3">
                <span className="input-group-text">Arrow Angle: {arrowAngle} degree</span>
                <input type="range" className="form-range" min="0" max="360" onChange={(evt) => setArrowAngle(evt.target.value || 0)} value={arrowAngle} />
              </div>

              <div className="input-group mb-3">
                <Select value={siteValue} onChange={onSiteChange} className="form-select" options={siteOptions} />
              </div>

              <ul className="list-group">
                {figures.map(figure =>
                    <>
                    <div
                      key={figure.id}
                      onClick={(evt) => { setCurrentEditBox(figure.id); } }
                      className={`list-group-item list-group-item-action d-flex justify-content-between align-items-start ${currentEditBoxActiveClass(figure)}`}
                      >
                        <div className="ms-2 me-auto">
                          <div className="fw-bold">{figure.type_name}</div>
                        </div>
                        <div
                          onClick={(evt) => { removeEditBox(figure.id); } }
                          className="btn btn-primary badge bg-primary rounded-pill"
                          role="button" data-bs-toggle="button">
                            X
                        </div>
                      </div>
                      {currentEditBox === figure.id && <Select className='form-select' options={[{value: 0, label: 'supine position' }]} />}
                      </>
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




            </p>
            <button onClick={save} className="btn btn-primary card-link">
              Save
            </button>
          </div>
        </div>
      </div>

    </div>
  </>);
}
