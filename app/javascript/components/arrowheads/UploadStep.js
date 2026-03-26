import React, { useState, useEffect } from 'react'

// Convert Uint8Array to base64
const uint8ArrayToBase64 = (uint8Array) => {
  let binary = ''
  const len = uint8Array.byteLength
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(uint8Array[i])
  }
  return window.btoa(binary)
}

export default function UploadStep ({ onNext, autoSelect = false, fixedImage = null, fixedObjectType = 'ceramics', demoImage = null }) {
  const [file, setFile] = useState(null)
  const [isDragOver, setIsDragOver] = useState(false)
  const [objectType, setObjectType] = useState(fixedObjectType)
  const [isFileSet, setIsFileSet] = useState(false)
  const [isDraggingSource, setIsDraggingSource] = useState(false)

  const handleDrop = (e) => {
    e.preventDefault()
    setIsDragOver(false)
    const droppedFiles = Array.from(e.dataTransfer.files)

    if (droppedFiles.length > 0) {
      // Check if it's an image file
      const file = droppedFiles[0]
      if (file.type.startsWith('image/')) {
        setFile(file)
        setIsFileSet(true)
      }
    } else if (autoSelect) {
      const defaultFile = new File([fixedImage], 'page_image.jpg', { type: 'image/jpeg' })
      setFile(defaultFile)
      setIsFileSet(true)
    }
  }

  const handleDragOver = (e) => {
    e.preventDefault()
    setIsDragOver(true)
  }

  const handleDragLeave = (e) => {
    // Only reset if we're leaving the dropzone area
    if (e.target === e.currentTarget) {
      setIsDragOver(false)
    }
  }

  const handleFileSelect = (e) => {
    const selectedFiles = Array.from(e.target.files)
    if (selectedFiles.length > 0) {
      setFile(selectedFiles[0]) // only the first file
      setIsFileSet(true)
    }
  }

  const handleNext = () => {
    if (file && onNext) {
      onNext(file, objectType) // pass the file and object type to the parent
    }
  }

  const handleSourceDragStart = (e) => {
    setIsDraggingSource(true)
    // Set drag image to null (no custom drag image)
    e.dataTransfer.effectAllowed = 'copy'
  }

  const handleSourceDragEnd = () => {
    setIsDraggingSource(false)
  }

  const handleSourceDragOver = (e) => {
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'
  }

  const handleDropFromSource = (e) => {
    e.preventDefault()
    setIsDragOver(false)
    setIsDraggingSource(false)

    // Create a file from the demo image
    if (demoImage) {
      const demoFile = new File([demoImage], 'demo.jpg', { type: 'image/jpeg' })
      setFile(demoFile)
      setIsFileSet(true)
    }
  }

  const handleSourceClick = () => {
    // Click on source box to auto-select
    if (demoImage) {
      const demoFile = new File([demoImage], 'demo.jpg', { type: 'image/jpeg' })
      setFile(demoFile)
      setIsFileSet(true)
    }
  }

  return (
    <div className='upload-step'>
      <div className='alert alert-info mb-3' role='alert'>
        <h5 className='alert-heading'>How to use this:</h5>
        {demoImage !== null
          ? <ul className='mb-0'>
            <li><strong>1. Upload Image:</strong> {autoSelect ? 'Drag demo.jpg from the source box to the upload box, or click the source box.' : 'Drag & drop an image file (JPG, PNG, GIF, WebP) or click to browse your files. Maximum size is 10MB recommended.'}</li>
            <li><strong>2. Select Vessel:</strong> The interface will auto-detect vessels for you.</li>
            <li><strong>3. Continue:</strong> View similar objects and a 3D model of the vessel.</li>
          </ul>
          : <ul className='mb-0'>
            <li><strong>1. Object Type:</strong> {autoSelect ? 'Ceramic analysis - automatically set to Ceramics' : 'Choose the type of artifact (Lithics, Graves, Arrowheads, or Ceramics) you are adding.'}</li>
            <li><strong>2. Upload Image:</strong> {autoSelect ? 'Drag demo.jpg from the source box to the upload box, or click the source box.' : 'Drag & drop an image file (JPG, PNG, GIF, WebP) or click to browse your files. Maximum size is 10MB recommended.'}</li>
            <li><strong>3. Review Features:</strong> The interface will auto-detect object types for you, but you will have the chance to adjust this later in the workflow.</li>
            <li><strong>4. Continue:</strong> Once your file is selected and ready, click the "Continue" button to proceed to the next step.</li>
            </ul>}
      </div>

      <div className='mb-3'>
        {!autoSelect &&
          <>
            <label htmlFor='objectType' className='form-label'>Object Type</label>
            <div className='form-select-wrapper'>
              <select
                id='objectType'
                className='form-select'
                value={objectType}
                onChange={(e) => setObjectType(e.target.value)}
                disabled={autoSelect}
              >
                <option value='lithics'>Lithics - Stone tools</option>
                <option value='grave'>Graves - Burial pits</option>
                <option value='arrowheads'>ArrowHeads - Lithic Arrowheads</option>
                <option value='ceramics'>Ceramics - Pottery and ceramic artifacts</option>
              </select>
            </div>
          </>}
      </div>
      <div className='upload-layout'>
        <div className='source-box-container'>
          <div
            className={`source-box ${isDraggingSource ? 'dragging' : ''}`}
            draggable={autoSelect && demoImage !== null}
            onDragStart={handleSourceDragStart}
            onDragEnd={handleSourceDragEnd}
            onDragOver={handleSourceDragOver}
            onDrop={handleDropFromSource}
            onClick={handleSourceClick}
          >
            {demoImage
              ? (
                <img
                  src={`data:image/jpeg;base64,${uint8ArrayToBase64(demoImage)}`}
                  alt='demo.jpg'
                  className='source-image img-fluid'
                />
                )
              : (
                <div className='source-placeholder'>
                  <span className='source-icon'>🖼️</span>
                  <span className='source-text'>demo.jpg</span>
                </div>
                )}
            <div className='source-caption'>
              {autoSelect ? 'Drag to upload' : 'Source: demo.jpg'}
            </div>
          </div>
        </div>

        <div
          className={`dropzone ${isDragOver ? 'active' : ''}`}
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
        >
          <div className='dropzone-content'>
            <input
              type='file'
              accept='image/*'
              onChange={handleFileSelect}
              style={{ display: 'none' }}
              id='fileInput'
              disabled={false}
            />
            <label htmlFor='fileInput' className='dropzone-btn'>
              <span className='dropzone-icon'>📤</span>
              <span className='dropzone-text'>
                {isDragOver ? 'Drop the file here...' : autoSelect ? 'Drag demo.jpg from the source box' : 'Drag & drop an image file here'}
              </span>
              <span className='dropzone-hint'> or click to browse</span>
            </label>
          </div>
          {demoImage === null &&
            <div className='dropzone-help'>
              <span className='help-item'>🖼️ Supports: JPG, PNG, GIF, WebP</span>
              <span className='help-item'>⏱️ Max: 10MB recommended</span>
            </div>}
        </div>
      </div>

      {file && (
        <ul className='file-list'>
          <li>{autoSelect ? 'page_image.jpg' : file.name}</li>
        </ul>
      )}

      <div className='next-button-area'>
        <button
          type='button'
          disabled={!isFileSet}
          onClick={handleNext}
          className='next-button'
        >
          <span className='button-icon'>🚀</span>
          <span className='button-text'>Continue</span>
          <span className='button-hint'>{isFileSet ? '(ready)' : '(select a file)'}</span>
        </button>
        {file && (
          <div className='file-info'>
            <span className='file-icon'>📎</span>
            <span className='file-name'>{autoSelect ? 'page_image.jpg' : file.name}</span>
          </div>
        )}
      </div>
    </div>
  )
}
