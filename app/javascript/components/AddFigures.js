import React from 'react'
import { Wizard, useWizard } from 'react-use-wizard'
import Select from 'react-select'
import { useFigureStore } from './store'

export function Box ({ onDraggingStart, active, figure: { id, x1, y1, x2, y2, type } }) {
  let color = 'black'
  if (active === id) {
    color = '#F44336'
  }

  function onMouseDown (figure) {
    return function (evt) {
      evt.preventDefault()
      onDraggingStart(evt, figure)
    }
  }

  return (
    <>
      <defs>
        <marker
          id='arrowhead' markerWidth='10' markerHeight='7'
          refX='0' refY='3.5' orient='auto'
        >
          <polygon points='0 0, 10 3.5, 0 7' />
        </marker>
      </defs>

      {(type === 'Spine' || type === 'CrossSectionArrow') &&
        <line
          fill='none'
          stroke={color}
          strokeWidth='2'
          x1={x1}
          y1={y1}
          x2={x2}
          y2={y2}
          markerEnd='url(#arrowhead)'
        />}

      {type !== 'Spine' && <rect
        fill='none'
        stroke={color}
        strokeOpacity={color === 'black' ? '0.2' : '1'}
        strokeWidth='3'
        x={x1}
        y={y1}
        width={x2 - x1}
        height={y2 - y1}
                           />}

      <circle
        onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 1 })}
        className='moveable-point'
        r='10'
        cx={x1}
        cy={y1}
        stroke='black'
      />
      <circle
        onMouseDown={onMouseDown({ figure: { id, x1, x2, y1, y2 }, point: 2 })}
        className='moveable-point'
        r='10'
        cx={x2}
        cy={y2}
        stroke='black'
      />
    </>
  )
}

function NewFigureDialog ({ closeDialog, addFigure }) {
  const [type, setType] = React.useState('Grave')

  return (
    <div className='modal d-block' aria-hidden='false'>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h1 className='modal-title fs-5' id='exampleModalLabel'>New Figure</h1>
            <button type='button' onClick={closeDialog} className='btn-close' data-bs-dismiss='modal' aria-label='Close' />
          </div>
          <div className='modal-body'>
            <form>
              <div className='input-group mb-3'>
                <select value={type} onChange={evt => setType(evt.target.value)} className='form-select' aria-label='Default select example'>
                  <option value='Grave'>Grave</option>
                  <option value='Spine'>Spine</option>
                  <option value='Skeleton'>Skeleton</option>
                  <option value='Skull'>Skull</option>
                  <option value='Scale'>Scale</option>
                  <option value='GraveCrossSection'>Grave Cross Section</option>
                  <option value='Arrow'>Arrow</option>
                  <option value='Good'>Good</option>
                  <option value='Map'>Map</option>
                  <option value='Artefact'>Artefact</option>
                  <option value='Ceramic'>Ceramic</option>
                </select>
              </div>
            </form>
          </div>
          <div className='modal-footer'>
            <button type='button' onClick={closeDialog} className='btn btn-secondary' data-bs-dismiss='modal'>Close</button>
            <button type='button' onClick={() => { addFigure(type); closeDialog() }} className='btn btn-primary'>Create</button>
          </div>
        </div>
      </div>
    </div>
  )
}

function Contour ({ figure, active }) {
  const points = [...figure.contour, figure.contour[0]].map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`).join(' ')
  return (
    <polyline
      points={points}
      fill={figure.id === active ? '#F4433699' : '#3F51B5'}
      stroke='#3F51B5'
      strokeWidth={5}
    />
  )
}

export default function AddFigure ({ image, pageFigures, page, next_url }) {
  const { figures, updateFigure, setFigures, addFigure, removeFigure } = useFigureStore()

  const [rendering, setRendering] = React.useState('boxes')
  const [draggingState, setDraggingState] = React.useState(null)
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false)
  const canvasRef = React.useRef(null)
  const [currentEditBox, setCurrentEditBox] = React.useState(null)

  React.useEffect(() => {
    setFigures(pageFigures)
  }, [])

  const token =
      document.querySelector('[name=csrf-token]').content

  function currentEditBoxActiveClass (figure) {
    if (figure.id === currentEditBox) {
      return ' active'
    }
  }

  function createNewFigure () {
    setCreatingNewFigure(true)
  }

  async function removeEditBox (id) {
    const response = await fetch(`/figures/${id}.json`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
    if (response.ok) {
      removeFigure(figures[id])
    } else {
      return Promise.reject(response)
    }
  }

  function onChangeFigure (id, figure) {
    setFigures(figures.map((currentFigure) => {
      if (currentFigure.id === figure.id) {
        return figure
      } else {
        return currentFigure
      }
    }))
  }

  function onDraggingStart (evt, data) {
    const figure = data.figure
    setCurrentEditBox(figure.id)
    let svgPoint = canvasRef.current.createSVGPoint()
    svgPoint.x = evt.clientX
    svgPoint.y = evt.clientY
    svgPoint = svgPoint.matrixTransform(canvasRef.current.getScreenCTM().inverse())

    let x = 0
    let y = 0
    if (data.point === 1) {
      x = figure.x1
      y = figure.y1
    } else {
      x = figure.x2
      y = figure.y2
    }

    setDraggingState({
      point: svgPoint,
      x: svgPoint.x - x,
      y: svgPoint.y - y,
      data
    })
  }

  async function createFigure (type) {
    const x1 = image.width * 0.3
    const x2 = image.width * 0.6

    const y1 = image.height * 0.4
    const y2 = image.height * 0.6

    const newFigure = { page_id: page.id, y1, y2, x1, x2, type }

    const response = await fetch('/figures.json', {
      method: 'POST',
      body: JSON.stringify({
        figure: {
          x1: newFigure.x1,
          x2: newFigure.x2,
          y1: newFigure.y1,
          y2: newFigure.y2,
          page_id: newFigure.page_id,
          type: newFigure.type,
          probability: 1
        }
      }),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
    if (response.ok) {
      const figure = await response.json()
      addFigure({ ...figure, type })
      setCurrentEditBox(figure.id)
    } else {
      return Promise.reject(response)
    }
  }

  function onDrag (evt) {
    if (draggingState !== null) {
      const figure = figures[draggingState.data.figure.id]

      draggingState.point.x = evt.clientX
      draggingState.point.y = evt.clientY
      const cursor = draggingState.point.matrixTransform(canvasRef.current.getScreenCTM().inverse())

      const x = cursor.x - draggingState.x
      const y = cursor.y - draggingState.y

      if (draggingState.data.point === 1) {
        updateFigure({ ...figure, x1: x, y1: y })
      } else {
        updateFigure({ ...figure, x2: x, y2: y })
      }
    }
  }

  return (
    <>
      {creatingNewFigure && <NewFigureDialog addFigure={createFigure} closeDialog={() => setCreatingNewFigure(false)} />}
      <div className='row'>
        <div className='col-md-8 card'>
          <h3>Page {page.number}</h3>
          <div className='form-check'>
            <select value={rendering} onChange={evt => setRendering(evt.target.value)} className='form-select' aria-label='Default select example'>
              <option value='boxes'>Show Bounding Boxes</option>
              <option value='contours'>Show Contours</option>
              <option value='nothing'>Show Nothing</option>
            </select>
          </div>
          <svg
            ref={canvasRef}
            onMouseMove={onDrag}
            onMouseUp={() => { setDraggingState(null) }}
            onMouseLeave={() => { setDraggingState(null) }}
            viewBox={`0 0 ${image.width} ${image.height}`}
            preserveAspectRatio='xMidYMid meet'
            xmlns='http://www.w3.org/2000/svg'
          >
            <image width={image.width} height={image.height} href={image.href} />
            {rendering === 'boxes' && Object.values(figures).map(figure => <Box canvas={canvasRef} key={figure.id} onDraggingStart={onDraggingStart} active={currentEditBox} figure={figure} />)}
            {rendering === 'contours' && figures.filter(figure => ['Grave', 'Arrow', 'Scale'].indexOf(figure.type) !== -1).map(figure => <Contour key={figure.id} active={currentEditBox} figure={figure} />)}
          </svg>
        </div>

        <div className='col-md-4'>
          <div style={{ position: 'sticky', top: 60 }} className='card'>
            <div className='card-body'>
              <div className='card-text'>
                <ul className='list-group'>
                  {Object.values(figures).map(figure =>
                    <React.Fragment key={figure.id}>
                      <div
                        onClick={() => { setCurrentEditBox(figure.id) }}
                        className={`list-group-item list-group-item-action d-flex justify-content-between align-items-start ${currentEditBoxActiveClass(figure)}`}
                      >
                        <div className='ms-2 me-auto'>
                          <div className='fw-bold'>{figure.type} {figure.id}</div>
                        </div>
                        <div
                          onClick={() => { removeEditBox(figure.id) }}
                          className='btn btn-primary badge bg-primary rounded-pill'
                          role='button' data-bs-toggle='button'
                        >
                          X
                        </div>
                      </div>
                      {currentEditBox === figure.id && figure.type === 'SkeletonFigure' &&
                        <div className='row mb-3 mt-3'>
                          <label className='col-sm-2 col-form-label'>Position</label>
                          <div className='col-sm-10'>
                            <select
                              value={figure.deposition_type}
                              className='form-select'
                              aria-label='Default select example'
                              onChange={(evt) => { onChangeFigure(figure.id, { ...figure, deposition_type: evt.target.value }) }}
                            >
                              <option value='unknown'>Unknown</option>
                              <option value='back'>Back</option>
                              <option value='side'>Side</option>
                            </select>
                          </div>
                        </div>}
                    </React.Fragment>
                  )}

                  <a
                    href='#'
                    onClick={(evt) => { evt.preventDefault(); createNewFigure() }}
                    className='list-group-item list-group-item-action d-flex justify-content-between align-items-start'
                  >
                    <div className='ms-2 me-auto'>
                      <div className='fw-bold'>New Figure</div>
                    </div>
                  </a>
                </ul>
              </div>
              <form action={next_url} method='post'>
                <input type='hidden' name='_method' value='patch' />
                <input type='hidden' name='authenticity_token' value={token} />
                {Object.values(figures).map(figure => {
                  const id = figure.id
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
                  )
                })}

                <input value='Save' type='submit' className='btn btn-primary card-link' />
              </form>

            </div>
          </div>
        </div>

      </div>
    </>
  )
}
