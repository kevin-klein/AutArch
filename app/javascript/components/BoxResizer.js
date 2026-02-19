import React from 'react'
import { useFigureStore } from './store'
import { Group, Stage, Layer, Circle, Image, Rect, Line, Transformer, Arrow, Shape } from 'react-konva'
import ManualContour, { calculateControlPoints } from './ManualContour'
import BoxCanvas from './BoxCanvas'

function NewFigureDialog ({ closeDialog, addFigure }) {
  const [type, setType] = React.useState('Spine')

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
                  <option value='Spine'>Spine</option>
                  <option value='SkeletonFigure'>Skeleton</option>
                  <option value='Scale'>Scale</option>
                  <option value='GraveCrossSection'>Grave Cross Section</option>
                  <option value='Arrow'>Arrow</option>
                  <option value='Good'>Artefact</option>
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

export default function BoxResizer ({ next_url, grave, sites, image, page }) {
  const { figures, updateFigure, setFigures, addFigure, removeFigure } = useFigureStore()

  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false)
  const [currentEditBox, setCurrentEditBox] = React.useState(grave.figures.filter((f) => f.type === 'Lithic')[0]?.id)

  // --- New state for drawing ---
  const [isDrawing, setIsDrawing] = React.useState(false)
  const [newFigureType, setNewFigureType] = React.useState(null)
  const [newFigureCoords, setNewFigureCoords] = React.useState(null)
  // -----------------------------

  const divRef = React.useRef(null)

  React.useEffect(() => {
    setFigures(grave.figures.map(figure => {
      if (figure.control_point_1_x === null) {
        const controlPoints = calculateControlPoints(figure)

        return {
          typeName: figure.type,
          ...figure,
          control_point_1_x: controlPoints[0].x,
          control_point_1_y: controlPoints[0].y,
          control_point_2_x: controlPoints[1].x,
          control_point_2_y: controlPoints[1].y,
          control_point_3_x: controlPoints[2].x,
          control_point_3_y: controlPoints[2].y,
          control_point_4_x: controlPoints[3].x,
          control_point_4_y: controlPoints[3].y,
          anchor_point_1_x: figure.x1,
          anchor_point_1_y: figure.y1,
          anchor_point_2_x: figure.x2,
          anchor_point_2_y: figure.y1,
          anchor_point_3_x: figure.x2,
          anchor_point_3_y: figure.y2,
          anchor_point_4_x: figure.x1,
          anchor_point_4_y: figure.y2
        }
      } else {
        return {
          typeName: figure.type,
          ...figure
        }
      }
    }))
  }, [])

  React.useEffect(() => {
    if (divRef.current) {
      if (isDrawing) {
        divRef.current.style.cursor = 'crosshair'
      } else {
        divRef.current.style.cursor = 'default'
      }
    }
  }, [isDrawing])

  const token =
      document.querySelector('[name=csrf-token]').content

  function currentEditBoxActiveClass (figure) {
    if (figure.id === currentEditBox) {
      return ' active'
    }
  }

  // This is for the dialog
  function createNewFigure () {
    setCreatingNewFigure(true)
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
    setFigures(Object.values(figures).map((currentFigure) => {
      if (currentFigure.id === figure.id) {
        return figure
      } else {
        return currentFigure
      }
    }))
  }

  function setManualBoundingBox (figure, checked) {
    if (checked && figure.bounding_box_angle === null) {
      const centerX = (figure.x1 + figure.x2) / 2
      const centerY = (figure.y1 + figure.y2) / 2
      const angle = 0
      const width = figure.x2 - figure.x1
      const height = figure.y2 - figure.y1
      onChangeFigure(figure.id, {
        ...figure,
        manual_bounding_box: checked,
        bounding_box_center_x: centerX,
        bounding_box_center_y: centerY,
        bounding_box_angle: angle,
        bounding_box_width: width,
        bounding_box_height: height
      })
    } else {
      onChangeFigure(figure.id, { ...figure, manual_bounding_box: checked })
    }
  }

  // --- Modified createFigure to accept coords ---
  async function createFigure (type, coords = null) {
    let x1, y1, x2, y2

    if (coords) {
      // Use coords from drawing
      x1 = coords.x1
      y1 = coords.y1
      x2 = coords.x2
      y2 = coords.y2
    } else if (grave !== undefined) {
      // Fallback to original logic (for dialog)
      if (type === 'Spine') {
        const graveWidth = grave.x2 - grave.x1
        const graveHeight = grave.y2 - grave.y1
        x1 = grave.x1 + graveWidth * 0.5
        x2 = grave.x1 + graveWidth * 0.5

        y1 = grave.y1 + graveHeight * 0.6
        y2 = grave.y1 + graveHeight * 0.4
      } else {
        const graveWidth = grave.x2 - grave.x1
        const graveHeight = grave.y2 - grave.y1
        x1 = grave.x1 + graveWidth * 0.3
        x2 = grave.x1 + graveWidth * 0.6

        y1 = grave.y1 + graveHeight * 0.4
        y2 = grave.y1 + graveHeight * 0.6
      }
    } else {
      // Default fallback
      x1 = 0; y1 = 0; x2 = 100; y2 = 100
    }

    const response = await fetch('/figures.json', {
      method: 'POST',
      body: JSON.stringify({
        grave_id: grave.id,
        figure: {
          x1, // Use derived x1
          x2, // Use derived x2
          y1, // Use derived y1
          y2, // Use derived y2
          page_id: page.id,
          type,
          parent_id: grave.id
        }
      }),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
    if (response.ok) {
      const newFigure = await response.json()
      addFigure({ ...newFigure, typeName: type })
      setCurrentEditBox(newFigure.id)
    } else {
      return Promise.reject(response)
    }
  }
  // ------------------------------------------

  const validations = ['Scale', 'Arrow', 'Spine', 'SkeletonFigure', 'GraveCrossSection'].map((item) => {
    const matchingFigure = Object.values(figures).filter(fig => fig.typeName === item)[0]
    if (matchingFigure === undefined) {
      if (item === 'SkeletonFigure' || item === 'Spine') {
        return (
          <li key={item} className='list-group-item alert-warning'>{item} is missing</li>
        )
      } else {
        return (
          <li key={item} className='list-group-item alert-danger'>{item} is missing</li>
        )
      }
    }
  })

  return (
    <>
      {/* This dialog is still used by the "New Figure" link */}
      {creatingNewFigure && <NewFigureDialog addFigure={createFigure} closeDialog={() => setCreatingNewFigure(false)} />}
      <div style={{ position: 'sticky', top: 0, display: 'flex', zIndex: 999 }}>
        <div className='btn-group' role='group' aria-label='Basic example'>
          {/* --- Modified buttons to use startDrawing --- */}
          <button type='button' style={{ backgroundColor: '#F44336' }} className='btn btn-secondary' onClick={() => startDrawing('Spine')}>Spine</button>
          <button type='button' style={{ backgroundColor: '#9575CD' }} className='btn btn-secondary' onClick={() => startDrawing('SkeletonFigure')}>Skeleton</button>
          <button type='button' style={{ backgroundColor: '#009688' }} className='btn btn-secondary' onClick={() => startDrawing('Arrow')}>Arrow</button>
          <button type='button' style={{ backgroundColor: '#26C6DA' }} className='btn btn-secondary' onClick={() => startDrawing('GraveCrossSection')}>GraveCrossSection</button>
          <button type='button' style={{ backgroundColor: '#4CAF50' }} className='btn btn-secondary' onClick={() => startDrawing('Good')}>Artefact</button>
          <button type='button' style={{ backgroundColor: '#FF9800' }} className='btn btn-secondary' onClick={() => startDrawing('Scale')}>Scale</button>
          {/* ------------------------------------------- */}
        </div>
      </div>

      <div className='row'>
        <div className='col-md-8 card' ref={divRef}>
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
              <h5 className='card-title'>Edit Grave</h5>
              <div className='card-text'>
                <ul className='list-group'>
                  {Object.values(figures).map(figure =>
                    <React.Fragment key={figure.id}>
                      <div
                        onClick={() => { setCurrentEditBox(figure.id) }}
                        className={`list-group-item list-group-item-action d-flex justify-content-between align-items-start ${currentEditBoxActiveClass(figure)}`}
                      >
                        <div className='ms-2 me-auto'>
                          <div className='fw-bold'>{figure.typeName === 'Good' ? 'Artefact' : figure.typeName}</div>
                        </div>
                        <div
                          onClick={() => { removeEditBox(figure.id) }}
                          className='btn btn-primary badge bg-primary rounded-pill'
                          role='button' data-bs-toggle='button'
                        >
                          X
                        </div>
                      </div>
                      {currentEditBox === figure.id && (figure.typeName === 'Grave' || figure.typeName === 'GraveCrossSection') &&
                        <div className='row mb-3 mt-3'>
                          <div className='form-check ms-3'>
                            <input
                              className='form-check-input'
                              type='checkbox'
                              checked={figure.manual_bounding_box}
                              onChange={(evt) => { setManualBoundingBox(figure, evt.target.checked) }}
                            />
                            <label className='form-check-label'>
                              manual bounding box
                            </label>
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
                      {figure.manual_bounding_box && <>
                        <input type='hidden' name={`figures[${id}][control_point_1_x]`} value={figure.control_point_1_x} />
                        <input type='hidden' name={`figures[${id}][control_point_2_x]`} value={figure.control_point_2_x} />
                        <input type='hidden' name={`figures[${id}][control_point_3_x]`} value={figure.control_point_3_x} />
                        <input type='hidden' name={`figures[${id}][control_point_4_x]`} value={figure.control_point_4_x} />

                        <input type='hidden' name={`figures[${id}][control_point_1_y]`} value={figure.control_point_1_y} />
                        <input type='hidden' name={`figures[${id}][control_point_2_y]`} value={figure.control_point_2_y} />
                        <input type='hidden' name={`figures[${id}][control_point_3_y]`} value={figure.control_point_3_y} />
                        <input type='hidden' name={`figures[${id}][control_point_4_y]`} value={figure.control_point_4_y} />

                        <input type='hidden' name={`figures[${id}][anchor_point_1_x]`} value={figure.anchor_point_1_x} />
                        <input type='hidden' name={`figures[${id}][anchor_point_2_x]`} value={figure.anchor_point_2_x} />
                        <input type='hidden' name={`figures[${id}][anchor_point_3_x]`} value={figure.anchor_point_3_x} />
                        <input type='hidden' name={`figures[${id}][anchor_point_4_x]`} value={figure.anchor_point_4_x} />

                        <input type='hidden' name={`figures[${id}][anchor_point_1_y]`} value={figure.anchor_point_1_y} />
                        <input type='hidden' name={`figures[${id}][anchor_point_2_y]`} value={figure.anchor_point_2_y} />
                        <input type='hidden' name={`figures[${id}][anchor_point_3_y]`} value={figure.anchor_point_3_y} />
                        <input type='hidden' name={`figures[${id}][anchor_point_4_y]`} value={figure.anchor_point_4_y} />

                        <input type='hidden' name={`figures[${id}][manual_bounding_box]`} value={figure.manual_bounding_box} />
                      </>}
                    </React.Fragment>
                  )
                })}

                <input value='Next' type='submit' className='btn btn-primary card-link mt-1' />
              </form>

              <ul className='list-group mt-3'>
                {validations}
              </ul>

            </div>
          </div>
        </div>

      </div>
    </>
  )
}
