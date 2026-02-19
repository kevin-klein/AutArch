import React from 'react'
import { Group, Stage, Layer, Circle, Image, Rect, Line, Transformer, Arrow, Shape } from 'react-konva'
import useImage from 'use-image'
import ManualContour from './ManualContour'

export function Box ({ onChangeFigure, onDraggingStart, active, figure, setActive }) {
  const { id, x1, y1, x2, y2, typeName } = figure

  let color = 'purple'
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

export default function BoxCanvas ({
  divRef,
  image,
  figures,
  onDraggingStart,
  currentEditBox,
  setCurrentEditBox,
  onChangeFigure,
  isDrawing,
  newFigureCoords,
  setNewFigureCoords,
  finishDrawing
}) {
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

  // Helper to get pointer position relative to image
  function getPointerPos (stage) {
    if (!stage) return null
    const pos = stage.getPointerPosition()
    if (!pos) return null // Pointer is not on stage
    const scale = stage.scaleX()
    const stagePos = stage.position()
    return {
      x: (pos.x - stagePos.x) / scale,
      y: (pos.y - stagePos.y) / scale
    }
  }

  function handleMouseDown (e) {
    if (!isDrawing) return
    const stage = e.target.getStage()
    const pos = getPointerPos(stage)
    if (!pos) return // Not on stage

    e.evt.preventDefault()
    setNewFigureCoords({
      x1: pos.x,
      y1: pos.y,
      x2: pos.x,
      y2: pos.y
    })
  }

  function handleMouseMove (e) {
    if (!isDrawing || !newFigureCoords) return
    const stage = e.target.getStage()
    const pos = getPointerPos(stage)
    if (!pos) return // Moved off stage

    e.evt.preventDefault()
    setNewFigureCoords({
      ...newFigureCoords,
      x2: pos.x,
      y2: pos.y
    })
  }

  function handleMouseUp (e) {
    if (!isDrawing) return
    e.evt.preventDefault()
    finishDrawing()
  }

  return (
    <Stage
      onWheel={handleWheel}
      scaleX={stageScale}
      scaleY={stageScale}
      x={stageX}
      y={stageY}
      width={dimensions.width}
      draggable={!isDrawing}
      height={dimensions.height}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
    >
      <Layer>
        <Image
          width={image.width}
          height={image.height}
          image={imageNode}
          x={0}
          y={0}
        />
        {/* Render the preview rectangle while drawing */}
        {isDrawing && newFigureCoords && (
          <Rect
            fill='rgba(244, 67, 54, 0.3)'
            stroke='#F44336'
            strokeWidth={2 / stageScale}
            x={Math.min(newFigureCoords.x1, newFigureCoords.x2)}
            y={Math.min(newFigureCoords.y1, newFigureCoords.y2)}
            width={Math.abs(newFigureCoords.x2 - newFigureCoords.x1)}
            height={Math.abs(newFigureCoords.y2 - newFigureCoords.y1)}
          />
        )}
        {Object.values(figures).map(figure => <Box onChangeFigure={onChangeFigure} canvas={null} key={figure.id} onDraggingStart={onDraggingStart} setActive={setCurrentEditBox} active={currentEditBox} figure={figure} />)}
      </Layer>
    </Stage>
  )
}
