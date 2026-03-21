import React, { useState } from 'react'

export default function UploadStep ({ onNext }) {
  const [file, setFile] = useState(null)
  const [isDragOver, setIsDragOver] = useState(false)
  const [objectType, setObjectType] = useState('Lithics')

  const handleDrop = (e) => {
    e.preventDefault()
    setIsDragOver(false)
    const droppedFiles = Array.from(e.dataTransfer.files)
    if (droppedFiles.length > 0) {
      setFile(droppedFiles[0])
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
      onNext(file, objectType) // pass the file and object type to the parent
    }
  }

  return (
    <div className='upload-step'>
      <div className='alert alert-info mb-3' role="alert">
        <h5 className="alert-heading">How to use this interface:</h5>
        <ul className="mb-0">
          <li><strong>1. Select Object Type:</strong> Choose the type of artifact (Lithics, Graves, Arrowheads, or Ceramics) you're adding.</li>
          <li><strong>2. Upload Image:</strong> Drag & drop an image file (JPG, PNG, GIF, WebP) or click to browse your files. Maximum size is 10MB recommended.</li>
          <li><strong>3. Review Features:</strong> The interface will auto-detect object types for you, but you'll have the chance to adjust this later in the workflow.</li>
          <li><strong>4. Continue:</strong> Once your file is selected and ready, click the "Continue" button to proceed to the next step.</li>
        </ul>
      </div>

      <div className='mb-3'>
        <label htmlFor='objectType' className='form-label'>Object Type</label>
        <div className='form-select-wrapper'>
          <select
            id='objectType'
            className='form-select'
            value={objectType}
            onChange={(e) => setObjectType(e.target.value)}
          >
            <option value='lithics'>Lithics - Stone tools</option>
            <option value='grave'>Graves - Burial pits</option>
            <option value='arrowheads'>ArrowHeads - Lithic Arrowheads</option>
            <option value='ceramics'>Ceramics - Pottery and ceramic artifacts</option>
          </select>
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
          />
          <label htmlFor='fileInput' className='dropzone-btn'>
            <span className='dropzone-icon'>📤</span>
            <span className='dropzone-text'>
              {isDragOver ? 'Drop the file here...' : 'Drag & drop an image file here'}
            </span>
            <span className='dropzone-hint'>or click to browse</span>
          </label>
        </div>
        <div className='dropzone-help'>
          <span className='help-item'>🖼️ Supports: JPG, PNG, GIF, WebP</span>
          <span className='help-item'>⏱️ Max: 10MB recommended</span>
        </div>
      </div>

      <div className='upload-features'>
        <div className='feature-item'>
          <span className='feature-icon'>✅</span>
          <span className='feature-text'>Auto-detect object type</span>
        </div>
        <div className='feature-item'>
          <span className='feature-icon'>⚡</span>
          <span className='feature-text'>Fast processing</span>
        </div>
      </div>

      {file && (
        <ul className='file-list'>
          <li>{file.name}</li>
        </ul>
      )}

      <div className='next-button-area'>
        <button
          type='button'
          disabled={!file}
          onClick={handleNext}
          className='next-button'
        >
          <span className='button-icon'>🚀</span>
          <span className='button-text'>Continue</span>
          <span className='button-hint'>{file ? '(ready)' : '(select a file)'}</span>
        </button>
        {file && (
          <div className='file-info'>
            <span className='file-icon'>📎</span>
            <span className='file-name'>{file.name}</span>
          </div>
        )}
      </div>
    </div>
  )
}
