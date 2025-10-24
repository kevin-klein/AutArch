import React from 'react'
import { useFigureStore } from './store'
import { Group, Stage, Layer, Circle, Image, Rect, Line, Transformer, Arrow, Shape } from 'react-konva'
import BoxCanvas from './BoxCanvas'

export default function AddFigure ({ image, pageFigures, page, next_url }) {
  const { figures, updateFigure, setFigures, addFigure, removeFigure } = useFigureStore()

  const canvasRef = React.useRef(null)

  const [currentEditBox, setCurrentEditBox] = React.useState(null)
  const divRef = React.useRef(null)

  const [isDrawing, setIsDrawing] = React.useState(false)
  const [newFigureType, setNewFigureType] = React.useState(null)
  const [newFigureCoords, setNewFigureCoords] = React.useState(null)

  React.useEffect(() => {
    if (divRef.current) {
      if (isDrawing) {
        divRef.current.style.cursor = 'crosshair'
      } else {
        divRef.current.style.cursor = 'default'
      }
    }
  }, [isDrawing])

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

  // --- New functions for drawing ---
  function startDrawing (type) {
    setIsDrawing(true)
    setNewFigureType(type)
    setNewFigureCoords(null) // Clear any previous drawing
    setCurrentEditBox(null) // Deselect any active box
  }

  async function finishDrawing () {
    if (!isDrawing || !newFigureCoords || !newFigureType) {
      setIsDrawing(false)
      setNewFigureType(null)
      setNewFigureCoords(null)
      return
    }

    // Prevent creating a zero-size box
    if (newFigureCoords.x1 === newFigureCoords.x2 || newFigureCoords.y1 === newFigureCoords.y2) {
      setIsDrawing(false)
      setNewFigureType(null)
      setNewFigureCoords(null)
      return
    }

    // Ensure x1,y1 is top-left and x2,y2 is bottom-right
    const coords = {
      x1: Math.min(newFigureCoords.x1, newFigureCoords.x2),
      y1: Math.min(newFigureCoords.y1, newFigureCoords.y2),
      x2: Math.max(newFigureCoords.x1, newFigureCoords.x2),
      y2: Math.max(newFigureCoords.y1, newFigureCoords.y2)
    }

    setIsDrawing(false)
    setNewFigureType(null)
    setNewFigureCoords(null)

    // Call the modified createFigure
    await createFigure(newFigureType, coords)
  }
  // ---------------------------------

  function onChangeFigure (id, figure) {
    setFigures(Object.values(figures).map((currentFigure) => {
      if (currentFigure.id === figure.id) {
        return figure
      } else {
        return currentFigure
      }
    }))
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

  async function createFigure (type, coords) {
    let x1, y1, x2, y2

    if (coords) {
      // Use coords from drawing
      x1 = coords.x1
      y1 = coords.y1
      x2 = coords.x2
      y2 = coords.y2
    } else {
      // Default fallback
      x1 = 0; y1 = 0; x2 = 100; y2 = 100
    }

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

  return (
    <>
      <div style={{ position: 'sticky', top: 0, display: 'flex', zIndex: 999 }}>
        <div className='btn-group' role='group' aria-label='Basic example'>
          <button type='button' style={{ backgroundColor: '#F44336', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('Spine')}>Spine</button>
          <button type='button' style={{ backgroundColor: '#9575CD', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('SkeletonFigure')}>Skeleton</button>
          <button type='button' style={{ backgroundColor: '#009688', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('Arrow')}>Arrow</button>
          <button type='button' style={{ backgroundColor: '#26C6DA', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('GraveCrossSection')}>GraveCrossSection</button>
          <button type='button' style={{ backgroundColor: '#4CAF50', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('Good')}>Artefact</button>
          <button type='button' style={{ backgroundColor: '#FF9800', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('Scale')}>Scale</button>
          <button type='button' style={{ backgroundColor: 'grey', color: 'white' }} className='btn btn-secondary' onClick={() => startDrawing('StoneTool')}>Lithic</button>
        </div>
      </div>

      <div className='row'>
        <div className='col-md-8 card' ref={divRef}>
          <h3>Page {page.number + 1}</h3>
          <BoxCanvas
            setCurrentEditBox={setCurrentEditBox}
            divRef={divRef}
            image={image}
            figures={figures}
            currentEditBox={currentEditBox}
            onChangeFigure={onChangeFigure}
            isDrawing={isDrawing}
            newFigureCoords={newFigureCoords}
            setNewFigureCoords={setNewFigureCoords}
            finishDrawing={finishDrawing}
          />
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
