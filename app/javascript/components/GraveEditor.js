/* eslint-disable react/prop-types */
import React from 'react';
import Select from 'react-select';
import {useQuery} from 'graphql-hooks';
import {GRAVE_EDITOR_QUERY} from './queries';

const genUUID = () =>
  ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
    (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
  );

function Box({setDraggingPoint, active, figure: { id, x1, y1, x2, y2, width, height, typeName}}) {
  let color = 'black';

  if(active === id) {
    color = 'red';
  }

  return (<React.Fragment>
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="7"
        refX="0" refY="3.5" orient="auto">
        <polygon points="0 0, 10 3.5, 0 7" />
      </marker>
    </defs>

    {(typeName === 'spine' || typeName === 'cross_section_arrow') &&
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

    {typeName !== 'spine' && <rect
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
  </React.Fragment>)
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

export default function BoxEditorWrapper({id}) {
  const {loading, error, data} = useQuery(GRAVE_EDITOR_QUERY, {
    variables: { id: parseInt(id) }
  });

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {JSON.stringify(error)}</p>;

  const grave = data.grave;

  return (
    <BoxEditor grave={grave} sites={data.sites} />
  );
}

function BoxEditor({grave, sites}) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [figures, setFigures] = React.useState(grave.figures);
  const [arrowAngle, setArrowAngle] = React.useState(grave.arrow?.angle || 0);
  const [showFigures, setShowFigures] = React.useState(true);
  const [draggingPoint, setDraggingPoint] = React.useState(null);
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false);
  const [isSaving, setIsSaving] = React.useState(false);
  const [site, setSite] = React.useState(grave.site_id);
  const canvasRef = React.useRef(null);
  const [currentEditBox, setCurrentEditBox] = React.useState(grave.figures.filter((f) => f.typeName == 'grave')[0]?.id);

  const angle = Math.abs(360 - arrowAngle);

  function currentEditBoxActiveClass(figure) {
    if(figure.id === currentEditBox) {
      return ' active';
    }
  }

  async function save() {
    setIsSaving(true);
    const response = await fetch('/graves/'+grave.id, safeCredentials({
      method: 'put',
      body: JSON.stringify({
        grave: {
          arrowAngle: arrowAngle,
          site_id: site,
          figures: figures.map((figure) => { return { typeName: figure.typeName, id: figure.id, x1: figure.x1, x2: figure.x2, y1: figure.y1, y2: figure.y2 };}),
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
    const grave = figures.filter(figure => figure.typeName === 'grave')[0];

    if(grave !== undefined) {
      const graveWidth = grave.x2 - grave.x1;
      const graveHeight = grave.y2 - grave.y1;
      const x1 = grave.x1 + graveWidth * 0.3;
      const x2 = grave.x1 + graveWidth * 0.6;

      const y1 = grave.y1 + graveHeight * 0.4;
      const y2 = grave.y1 + graveHeight * 0.6;

      const newFigure = { ...grave, y1: y1, y2: y2, x1: x1, x2: x2, typeName: type, id: genUUID() };
      setFigures([...figures, newFigure]);
      setCurrentEditBox(newFigure.id);
    }
    else{
      const newFigure = { typeName: type, id: genUUID(), x1: 0, y1: 0, x2: 100, y2: 100 };
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

  const siteOptions = sites.map((site) => { return { value: site.id, label: site.name }; });
  const siteValue = siteOptions.filter((option) => option.value === site )[0];

  let arrowView = null;
  const arrow = grave.figures.filter((f) => f.typeName == 'arrow')[0];
  if(arrow) {
    const arrowCenterX = (arrow.x1 + arrow.x2) / 2;
    const arrowCenterY = (arrow.y1 + arrow.y2) / 2;

    arrowView = (<svg width="512" height="200" viewBox={`${arrow.x1} ${arrow.y1} ${arrow.x2 - arrow.x1} ${arrow.y2 - arrow.y1}`}>
      <image width={grave.page.image.width} height={grave.page.image.height} href={grave.page.image.data} />
      <g transform={`rotate(${angle} ${arrowCenterX} ${arrowCenterY}) translate(${arrowCenterX - 100} ${arrowCenterY - 80})`} stroke="blue" shapeRendering="geometricPrecision">
        <line x1="100" y1="20" x2="100" y2="150" />
        <line x1="100" x2="110" y1="20" y2="40" />
        <line x1="100" x2="90" y1="20" y2="40" />
      </g>
    </svg>);
  }

  // transform={"rotate(" + angle + " 100 85)"}
  return (<>
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
          onMouseUp={() => { setDraggingPoint(null); }}
          onMouseLeave={() => { setDraggingPoint(null); }}
          viewBox={`0 0 ${grave.page.image.width} ${grave.page.image.height}`}
          preserveAspectRatio="xMidYMid meet"
          xmlns="http://www.w3.org/2000/svg"
        >
          <image width={grave.page.image.width} height={grave.page.image.height} href={grave.page.image.data} />
          {showFigures && figures.map(figure => <Box key={figure.id} setDraggingPoint={setDraggingFigure} active={currentEditBox} figure={figure} />)}
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
                        <div className="fw-bold">{figure.typeName}</div>
                      </div>
                      <div
                        onClick={() => { removeEditBox(figure.id); } }
                        className="btn btn-primary badge bg-primary rounded-pill"
                        role="button" data-bs-toggle="button">
                          X
                      </div>
                    </div>
                    {currentEditBox === figure.id && figure.typeName === 'skeleton' &&
                      <>
                        <Select className='form-select' options={[{value: 0, label: 'supine position' }]} />
                        <a href={`#/skeletons/${figure.skeletons[0].id}`}>Edit</a>
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
            <button onClick={save} className="btn btn-primary card-link">
              Save
            </button>
          </div>
        </div>
      </div>

    </div>
  </>);
}
