import React from 'react';
import safeCredentials from './fetchHelper';
import Select from 'react-select'
import $ from 'jquery';

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
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="7"
      refX="0" refY="3.5" orient="auto">
        <polygon points="0 0, 10 3.5, 0 7" />
      </marker>
    </defs>

    {(type_name === 'spine' || type_name === 'cross_section_arrow') && <>
      <line
        fill='none'
        stroke={color}
        strokeWidth="2"
        x1={x1}
        y1={y1}
        x2={x2}
        y2={y2}

        marker-end="url(#arrowhead)" />
      />
      </>
    }

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
  const [type, setType] = React.useState('spine');

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
                <option value="spine">Spine</option>
                <option value="skeleton">Skeleton</option>
                <option value="skull">Skull</option>
                <option value="scale">Scale</option>
                <option value="grave_cross_section">Grave Cross Section</option>
                <option value="arrow">Arrow</option>
                <option value="good">Good</option>
                <option value="cross_section_arrow">Cross Section Arrow</option>
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

function useStyle(element) {
  return function(style) {
    const savedBodyStyle = React.useRef({});

    React.useEffect(() => {
      const backupBodyStyle = {};
      Object.entries(style).forEach(([key, value]) => {
        backupBodyStyle[key] = document.body.style[key];
        document[element].style[key] = value;
      });
      savedBodyStyle.current = backupBodyStyle;

      return function cleanup() {
        Object.entries(savedBodyStyle).forEach(([key, value]) => {
          document[element].style[key] = value;
        });
      }
    }, []);
  }
}

function useHtmlStyle(style) {
  return useStyle('documentElement')(style);
}

function useBodyStyle(style) {
  return useStyle('body')(style);
}

function FullScreenWrapper({children}) {
  // useHtmlStyle({
  //   margin: 0,
  //   padding: 0,
  //   height: '100%',
  // })

  // useBodyStyle({
  //   margin: 0,
  //   padding: 0,
  //   height: '100%',
  //   maxHeight: '100%',
  //   // float: 'left',
  //   width: '100%',
  // })

  return children;
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
  const canvasRef = React.useRef(null);

  const [currentEditBox, setCurrentEditBox] = React.useState(props.figures.filter((f) => f.type_name == 'grave')[0]?.id);

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
      const graveWidth = grave.x2 - grave.x1;
      const graveHeight = grave.y2 - grave.y1;
      const x1 = grave.x1 + graveWidth * 0.3;
      const x2 = grave.x1 + graveWidth * 0.6;

      const y1 = grave.y1 + graveHeight * 0.4;
      const y2 = grave.y1 + graveHeight * 0.6;

      const newFigure = { ...grave, y1: y1, y2: y2, x1: x1, x2: x2, type_name: type, id: genUUID() };
      setFigures([...figures, newFigure]);
      setCurrentEditBox(newFigure.id);
    }
    else{
      const newFigure = { type_name: type, id: genUUID(), x1: 0, y1: 0, x2: 100, y2: 100 };
      setFigures([...figures, newFigure]);
      setCurrentEditBox(newFigure.id);
    }
  }

  function onSiteChange(evt) {
    setSite(evt.value);
  }

  function onDrag(evt) {
    // var coord = getMousePosition(evt);
    if(draggingPoint !== null) {
      setFigures(figures.map((figure) => {
        const factor = 2.5;
        if(figure.id === draggingPoint.figure.id) {
          if(draggingPoint.point === 1) {
            return { ...figure, x1: figure.x1 + evt.movementX * factor, y1: figure.y1 + evt.movementY * factor };
          }
          else {
            return { ...figure, x2: figure.x2 + evt.movementX * factor, y2: figure.y2 + evt.movementY * factor };
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

  const arrow = props.figures.filter((f) => f.type_name == 'arrow')[0];
  const arrowCenterX = (arrow.x1 + arrow.x2) / 2;
  const arrowCenterY = (arrow.y1 + arrow.y2) / 2;

  // transform={"rotate(" + angle + " 100 85)"}
  return (<>
    {creatingNewFigure && <NewFigureDialog addFigure={addFigure} closeDialog={() => setCreatingNewFigure(false)} />}
    <FullScreenWrapper>
      <div className='row'>
        <div className='col-md-8'>
          <svg width="512" height="200" viewBox={`${arrow.x1} ${arrow.y1} ${arrow.x2 - arrow.x1} ${arrow.y2 - arrow.y1}`}>
            <image width={props.width} height={props.height} href={props.image} />
            <g transform={`rotate(${angle} ${arrowCenterX} ${arrowCenterY}) translate(${arrowCenterX - 100} ${arrowCenterY - 80})`} stroke="blue" shapeRendering="geometricPrecision">
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
            ref={canvasRef}
            onMouseMove={onDrag}
            onMouseUp={(evt) => { setDraggingPoint(null); }}
            onMouseLeave={(evt) => { setDraggingPoint(null); }}
            viewBox={`0 0 ${props.width} ${props.height}`}
            preserveAspectRatio="xMidYMid meet"
            xmlns="http://www.w3.org/2000/svg"
            >
            <image width={props.width} height={props.height} href={props.image} />
            {showFigures && figures.map(figure => <Box key={figure.id} setDraggingPoint={setDraggingFigure} active={currentEditBox} figure={figure} />)}
          </svg>
        </div>

        <div className='col-md-4'>
          <div style={{position: 'sticky', top: 60}} className="card">
            <div className="card-body">
              <h5 className="card-title">Edit Grave</h5>
              <p className="card-text">
                <div className="input-group mb-3">
                  <span className="input-group-text">Arrow Angle: {arrowAngle} degree</span>
                  <button class='btn btn-info' onClick={() => setArrowAngle((arrowAngle + 180) % 360)}>Flip Angle</button>
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
                      {currentEditBox === figure.id && figure.type_name === 'skeleton' &&
                        <>
                          <Select className='form-select' options={[{value: 0, label: 'supine position' }]} />
                          <a href={`/skeletons/${figure.skeletons[0].id}/edit`}>Edit</a>
                        </>}
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
    </FullScreenWrapper>
  </>);
}
