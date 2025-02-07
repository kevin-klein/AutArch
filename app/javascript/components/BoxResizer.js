import React from 'react'
import { Wizard, useWizard } from 'react-use-wizard'
import Select from 'react-select'
import { useFigureStore } from './store'
import { Group, Stage, Layer, Circle, Image, Rect, Line, Transformer, Arrow, Shape } from 'react-konva'
import useImage from 'use-image'
import ManualContour, { calculateControlPoints } from './ManualContour'

function rotatePoint (x, y, figure) {
  const centerX = (figure.x2 + figure.x1) / 2
  const centerY = (figure.y2 + figure.y1) / 2
  let newX = (x - centerX) * Math.cos(-figure.bounding_box_angle) - (y - centerY) * Math.sin(-figure.bounding_box_angle)
  let newY = (x - centerX) * Math.sin(-figure.bounding_box_angle) + (y - centerY) * Math.cos(-figure.bounding_box_angle)
  newX = newX + centerX
  newY = newY + centerY

  return {
    x: newX,
    y: newY
  }
}

export function Box ({ onChangeFigure, onDraggingStart, active, figure, setActive }) {
  const { id, x1, y1, x2, y2, typeName } = figure

  let color = 'black'
  if (active === id) {
    color = '#F44336'
  }
  const isSelected = active === id
  const shapeRef = React.useRef()
  const trRef = React.useRef()

  React.useEffect(() => {
    if (isSelected && !figure.manual_bounding_box && typeName !== 'Spine') {
      trRef.current.nodes([shapeRef.current])
      trRef.current.getLayer().batchDraw()
    }
  }, [isSelected])

  if (figure.manual_bounding_box) {
    return <ManualContour onChangeFigure={onChangeFigure} active={active} onDraggingStart={onDraggingStart} figure={figure} color={color} />
  }

  return (
    <>
      {(typeName === 'Spine') &&
        <>
          <Arrow
            fill={null}
            stroke={color}
            strokeWidth={3}
            points={[x1, y1, x2, y2]}
            ref={shapeRef}
            onClick={() => setActive(id)}
            onTap={() => setActive(id)}
          />
          <Circle
            x={x1}
            y={y1}
            radius={10}
            stroke={color}
            draggable
            onDragMove={e => {
              onChangeFigure(figure.id, {
                ...figure,
                x1: e.target.x(),
                y1: e.target.y()
              })
            }}
          />
          <Circle
            x={x2}
            y={y2}
            radius={10}
            stroke={color}
            draggable
            onDragMove={e => {
              onChangeFigure(figure.id, {
                ...figure,
                x2: e.target.x(),
                y2: e.target.y()
              })
            }}
          />
        </>}

      {typeName !== 'Spine' && <Rect
        fill={null}
        ref={shapeRef}
        stroke={color}
        fillEnabled={false}
        strokeWidth={3}
        x={x1}
        y={y1}
        width={x2 - x1}
        height={y2 - y1}
        onClick={() => setActive(id)}
        onTap={() => setActive(id)}
        onTransformEnd={(e) => {
          const node = shapeRef.current
          const scaleX = node.scaleX()
          const scaleY = node.scaleY()

          node.scaleX(1)
          node.scaleY(1)

          const width = node.width() * scaleX
          const height = node.height() * scaleY

          onChangeFigure(figure.id, {
            ...figure,
            x1: node.x(),
            y1: node.y(),
            x2: node.x() + width,
            y2: node.y() + height
          })
        }}
                               />}

      {isSelected && typeName !== 'Spine' && (
        <Transformer
          ref={trRef}
          rotateEnabled={false}
          keepRatio={false}
          boundBoxFunc={(oldBox, newBox) => {
            if (newBox.width < 5 || newBox.height < 5) {
              return oldBox
            }
            return newBox
          }}
        />
      )}
    </>
  )
}

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

function Canvas ({ divRef, image, figures, onDraggingStart, currentEditBox, setCurrentEditBox, onChangeFigure }) {
  const [dimensions, setDimensions] = React.useState({
    width: 0,
    height: 0
  })
  const [stageScale, setStageScale] = React.useState(1)
  const [stageX, setStageX] = React.useState(0)
  const [stageY, setStageY] = React.useState(0)
  React.useEffect(() => {
    setDimensions({
      width: divRef.current.offsetWidth,
      height: (divRef.current.offsetWidth / image.width) * image.height
    })
    setStageScale(divRef.current.offsetWidth / image.width)
  }, [])
  const [imageNode] = useImage(image.href)

  function handleWheel (e) {
    e.evt.preventDefault()

    const scaleBy = 1.3
    const stage = e.target.getStage()
    const oldScale = stage.scaleX()
    const mousePointTo = {
      x: stage.getPointerPosition().x / oldScale - stage.x() / oldScale,
      y: stage.getPointerPosition().y / oldScale - stage.y() / oldScale
    }

    const newScale = e.evt.deltaY < 0 ? oldScale * scaleBy : oldScale / scaleBy

    setStageScale(newScale)
    setStageX(-(mousePointTo.x - stage.getPointerPosition().x / newScale) * newScale)
    setStageY(-(mousePointTo.y - stage.getPointerPosition().y / newScale) * newScale)
  }

  return (
    <Stage
      onWheel={handleWheel}
      scaleX={stageScale}
      scaleY={stageScale}
      x={stageX}
      y={stageY}
      width={dimensions.width}
      draggable
      height={dimensions.height}
    >
      <Layer>
        <Image
          width={image.width}
          height={image.height}
          image={imageNode}
          x={0}
          y={0}
        />
        {Object.values(figures).map(figure => <Box onChangeFigure={onChangeFigure} canvas={null} key={figure.id} onDraggingStart={onDraggingStart} setActive={setCurrentEditBox} active={currentEditBox} figure={figure} />)}
      </Layer>
    </Stage>
  )
}

function BoxResizer ({ next_url, grave, sites, image, page }) {
  const { figures, updateFigure, setFigures, addFigure, removeFigure } = useFigureStore()

  const [rendering, setRendering] = React.useState('boxes')
  const [draggingState, setDraggingState] = React.useState(null)
  const [creatingNewFigure, setCreatingNewFigure] = React.useState(false)
  const [currentEditBox, setCurrentEditBox] = React.useState(grave.figures.filter((f) => f.type == 'Grave')[0]?.id)
  // const graveFigure = figures.filter(figure => figure.id === grave.id)[0];

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

  function onDraggingStart (evt, data) {
    const figure = data.figure
    setCurrentEditBox(figure.id)
    let svgPoint = canvasRef.current.createSVGPoint()
    svgPoint.x = evt.clientX
    svgPoint.y = evt.clientY
    svgPoint = svgPoint.matrixTransform(canvasRef.current.getScreenCTM().inverse())

    setDraggingState({
      point: svgPoint,
      x1: svgPoint.x - figure.x1,
      y1: svgPoint.y - figure.y1,
      x2: svgPoint.x - figure.x2,
      y2: svgPoint.y - figure.y2,
      data
    })
  }

  async function createFigure (type) {
    const grave = Object.values(figures).filter(figure => figure.typeName === 'Grave')[0]

    let newFigure = null
    if (grave !== undefined) {
      if (type === 'Spine') {
        const graveWidth = grave.x2 - grave.x1
        const graveHeight = grave.y2 - grave.y1
        const x1 = grave.x1 + graveWidth * 0.5
        const x2 = grave.x1 + graveWidth * 0.5

        const y1 = grave.y1 + graveHeight * 0.6
        const y2 = grave.y1 + graveHeight * 0.4

        newFigure = { ...grave, page_id: page.id, y1, y2, x1, x2, typeName: type }
      } else {
        const graveWidth = grave.x2 - grave.x1
        const graveHeight = grave.y2 - grave.y1
        const x1 = grave.x1 + graveWidth * 0.3
        const x2 = grave.x1 + graveWidth * 0.6

        const y1 = grave.y1 + graveHeight * 0.4
        const y2 = grave.y1 + graveHeight * 0.6

        newFigure = { ...grave, page_id: page.id, y1, y2, x1, x2, typeName: type }
      }
    } else {
      newFigure = { typeName: type, page_id: page.id, x1: 0, y1: 0, x2: 100, y2: 100 }
    }

    const response = await fetch('/figures.json', {
      method: 'POST',
      body: JSON.stringify({
        grave_id: grave.id,
        figure: {
          x1: newFigure.x1,
          x2: newFigure.x2,
          y1: newFigure.y1,
          y2: newFigure.y2,
          page_id: newFigure.page_id,
          type: newFigure.typeName,
          parent_id: grave.id
        }
      }),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
    if (response.ok) {
      newFigure = await response.json()
      addFigure({ ...newFigure, typeName: type })
      setCurrentEditBox(newFigure.id)
    } else {
      return Promise.reject(response)
    }
  }

  function onSiteChange (evt) {
    setSite(evt.value)
  }

  function onDrag (evt) {
    if (draggingState !== null) {
      const figure = figures[draggingState.data.figure.id]

      draggingState.point.x = evt.clientX
      draggingState.point.y = evt.clientY
      const cursor = draggingState.point.matrixTransform(canvasRef.current.getScreenCTM().inverse())

      if (evt.ctrlKey) {
        const x1 = cursor.x - draggingState.x1
        const y1 = cursor.y - draggingState.y1

        const x2 = cursor.x - draggingState.x2
        const y2 = cursor.y - draggingState.y2
        updateFigure({ ...figure, x1, y1, x2, y2 })
      } else {
        if (draggingState.data.point === 1) {
          let x = cursor.x - draggingState.x1
          let y = cursor.y - draggingState.y1

          if (figure.bounding_box_angle !== null) {
            const result = rotatePoint(x, y, figure)
            x = result.x
            y = result.y
          }
          updateFigure({ ...figure, x1: x, y1: y })
        } else {
          let x = cursor.x - draggingState.x2
          let y = cursor.y - draggingState.y2

          if (figure.bounding_box_angle !== null) {
            const result = rotatePoint(x, y, figure)
            x = result.x
            y = result.y
          }
          updateFigure({ ...figure, x2: x, y2: y })
        }
      }
    }
  }

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
      {creatingNewFigure && <NewFigureDialog addFigure={createFigure} closeDialog={() => setCreatingNewFigure(false)} />}
      <div className='row'>
        <div className='col-md-8 card' ref={divRef}>
          <div className='form-check'>
            <div className='btn-group' role='group' aria-label='Basic example'>
              <button type='button' style={{ backgroundColor: '#F44336' }} className='btn btn-secondary' onClick={() => createFigure('Spine')}>Spine</button>
              <button type='button' style={{ backgroundColor: '#9575CD' }} className='btn btn-secondary' onClick={() => createFigure('SkeletonFigure')}>Skeleton</button>
              <button type='button' style={{ backgroundColor: '#009688' }} className='btn btn-secondary' onClick={() => createFigure('Arrow')}>Arrow</button>
              <button type='button' style={{ backgroundColor: '#26C6DA' }} className='btn btn-secondary' onClick={() => createFigure('GraveCrossSection')}>GraveCrossSection</button>
              <button type='button' style={{ backgroundColor: '#4CAF50' }} className='btn btn-secondary' onClick={() => createFigure('Good')}>Artefact</button>
              <button type='button' style={{ backgroundColor: '#FF9800' }} className='btn btn-secondary' onClick={() => createFigure('Scale')}>Scale</button>
            </div>
          </div>
          <Canvas
            setCurrentEditBox={setCurrentEditBox}
            divRef={divRef}
            image={image}
            figures={figures}
            onDraggingStart={onDraggingStart}
            currentEditBox={currentEditBox}
            onChangeFigure={onChangeFigure}
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

export default function (props, railsContext) {
  return () => <BoxResizer {...props} />
}
