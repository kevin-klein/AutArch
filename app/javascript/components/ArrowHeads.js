import React, { useState, useRef, useEffect } from 'react'
import { Stage, Layer, Rect, Transformer, Image as KonvaImage } from 'react-konva'
import { Box } from './BoxCanvas'

function UploadStep ({ onNext }) {
  const [file, setFile] = useState(null)
  const [isDragOver, setIsDragOver] = useState(false)

  const handleDrop = (e) => {
    e.preventDefault()
    setIsDragOver(false)
    const droppedFiles = Array.from(e.dataTransfer.files)
    if (droppedFiles.length > 0) {
      setFile(droppedFiles[0]) // take only the first file
    }
  }

  const handleDragOver = (e) => {
    e.preventDefault()
    setIsDragOver(true)
  }

  const handleDragLeave = () => {
    setIsDragOver(false)
  }

  const handleFileSelect = (e) => {
    const selectedFiles = Array.from(e.target.files)
    if (selectedFiles.length > 0) {
      setFile(selectedFiles[0]) // only the first file
    }
  }

  const handleNext = () => {
    if (file && onNext) {
      onNext(file) // pass the single file to the parent
    }
  }

  return (
    <div className='upload-step'>
      <div
        className={`dropzone ${isDragOver ? 'active' : ''}`}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
      >
        <input
          type='file'
          accept='image/*,.pdf'
          onChange={handleFileSelect}
          style={{ display: 'none' }}
          id='fileInput'
        />
        <label htmlFor='fileInput' style={{ cursor: 'pointer' }}>
          {isDragOver ? 'Drop the file here...' : 'Drag & drop a file here or click to select'}
        </label>
      </div>

      {file && (
        <ul className='file-list'>
          <li>{file.name}</li>
        </ul>
      )}

      <button
        type='button'
        disabled={!file}
        onClick={handleNext}
        className='next-button'
      >
        Next
      </button>
    </div>
  )
}

/**
 * Convert an array of {min_x, min_y, max_x, max_y} into
 * { id, x, y, width, height } that Konva expects.
 */
const normalizeBoxes = (boxes) =>
  boxes.map((b, idx) => {
    const [minX, minY, maxX, maxY] = b.box
    return {
      id: idx,
      x1: minX,
      y1: minY,
      x2: maxX,
      y2: maxY,
      typeName: b.label
    }
  })

function Boxes ({ boxes, image, onNext, onBack, onChange }) {
  // Keep a local copy of the boxes so we can mutate them
  const [localBoxes, setLocalBoxes] = useState(() => normalizeBoxes(boxes))
  const [selectedId, setSelectedId] = useState(null)
  const trRef = useRef()
  const stageRef = useRef()
  const divRef = useRef()
  const [currentEditBox, setCurrentEditBox] = React.useState(null)

  const [dimensions, setDimensions] = React.useState({
    width: 0,
    height: 0
  })

  const [stageScale, setStageScale] = React.useState(1)

  React.useEffect(() => {
    setDimensions({
      width: divRef.current.offsetWidth,
      height: (divRef.current.offsetWidth / image.width) * image.height
    })
    setStageScale(divRef.current.offsetWidth / image.width)
  }, [])

  // When the user drags or resizes a box
  const handleTransformEnd = (e) => {
    const node = e.target
    const index = localBoxes.findIndex((b) => b.id === node.id())
    const scaleX = node.scaleX()
    const scaleY = node.scaleY()

    // Reset scale to 1 after transform
    node.scaleX(1)
    node.scaleY(1)

    const newBox = {
      ...localBoxes[index],
      x: node.x(),
      y: node.y(),
      width: Math.max(5, node.width() * scaleX),
      height: Math.max(5, node.height() * scaleY)
    }

    const updated = [...localBoxes]
    updated[index] = newBox
    setLocalBoxes(updated)
    onChange && onChange(updated.map(b => ({
      min_x: b.x,
      min_y: b.y,
      max_x: b.x + b.width,
      max_y: b.y + b.height
    })))
  }

  return (
    <div className='row'>
      <div className='col-md-8 card' ref={divRef}>
        <h3>Resize Boxes</h3>

        {/* Simple controls */}
        <div style={{ marginBottom: 10 }}>
          <button className='btn btn-default' onClick={onBack}>Back</button>
          <button className='btn btn-default' onClick={onNext} disabled={localBoxes.length === 0}>Next</button>
        </div>

        {/* Konva stage */}
        <Stage
          scaleX={stageScale}
          scaleY={stageScale}
          width={dimensions.width}
          height={dimensions.height}
          ref={stageRef}
          style={{ border: '1px solid gray' }}
        >
          <Layer>
            <KonvaImage
              width={image.width}
              height={image.height}
              image={image}
              x={0}
              y={0}
            />

            {localBoxes.map((box) => (
              <Box fillEnabled fill='rgba(255, 0, 0, 0.7)' key={box.id} figure={box} active={currentEditBox} setActive={setCurrentEditBox} />
            ))}
          </Layer>
        </Stage>
      </div>
    </div>
  )
}

function Contours () {

}

function TableExport () {

}

export default function () {
  const [currentStep, setCurrentStep] = useState(0)
  const [boxes, setBoxes] = useState([]) // boxes returned from /size_figures/boxes
  const [uploading, setUploading] = useState(false)
  const [image, setImage] = useState(null)

  async function uploadImage (file) {
    const formData = new FormData()
    formData.append('image', file)

    try {
    // Send the request
      const response = await fetch('/size_figures/boxes', {
        method: 'POST',
        body: formData
      // Optional: add headers if your API expects them
      // headers: { 'Accept': 'application/json' },
      })

      // Check for HTTP errors
      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Upload failed: ${errorText}`)
      }

      // Parse JSON (or whatever your endpoint returns)
      const result = await response.json()
      return result // e.g., { url: 'https://...', id: 123 }
    } catch (err) {
      console.error('Error uploading image:', err)
      throw err // Re‑throw so callers can handle it
    } finally {
      setUploading(false)
    }
  }

  /* ---------- step navigation ---------- */
  const goNext = async (payload) => {
    if (payload && payload.file) {
      const imageUrl = URL.createObjectURL(payload.file)
      const imageObject = new Image()
      imageObject.src = imageUrl
      setImage(imageObject)
      setUploading(true)
      try {
        const res = await uploadImage(payload.file)
        setBoxes(res.boxes || []) // store the boxes for the next step
      } catch (e) {
        console.error(e)
        // You could add an error state here and show a message to the user
      }
      setCurrentStep((s) => s + 1)
    } else {
      setCurrentStep((s) => s + 1)
    }
  }

  const goBack = () => setCurrentStep((s) => Math.max(0, s - 1))

  const steps = [
    <UploadStep
      key='upload'
      onNext={(file) => goNext({ file })}
    />,
    <Boxes
      key='resize'
      boxes={boxes}
      image={image}
      onNext={goNext}
      onBack={goBack}
    />,
    <Contours
      key='select'
      onNext={goNext}
      onBack={goBack}
    />,
    <TableExport
      key='export'
      onBack={goBack}
    />
  ]

  return (
    <div className='upload-wizard'>
      <h2>Step {currentStep + 1} of {steps.length}</h2>

      {uploading && (
        <div className='progress-container' style={{ marginBottom: '1rem' }}>
          <progress style={{ width: '100%' }} />
          <span>Processing Image ....</span>
        </div>
      )}

      {steps[currentStep]}
    </div>
  )
}
