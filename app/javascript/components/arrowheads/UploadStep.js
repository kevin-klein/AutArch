import React, { useState, useEffect } from 'react'
import SharedButton from '../SharedButton'
import { t } from '../../utils/i18n'

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
        <h5 className='alert-heading'>{t('howToUse')}</h5>
        {demoImage !== null
          ? <ul className='mb-0'>
            <li><strong>1. {t('uploadImage')}:</strong> {autoSelect ? t('dragImage') : t('uploadInstructions')}</li>
            <li><strong>2. {t('selectVessel')}:</strong> {t('selectVesselInstructions')}</li>
            <li><strong>3. {t('similarity')}</strong> {t('similarityInstructions')}</li>
          </ul>
          : <ul className='mb-0'>
            <li><strong>1. {t('objectTypeInfo')}:</strong> {autoSelect ? t('ceramics') : t('objectTypeInfo')}</li>
            <li><strong>2. {t('upload')} {t('image')}:</strong> {autoSelect ? t('dragImage') : t('uploadInstructions')}</li>
            <li><strong>3. {t('reviewFeatures')}:</strong> {t('reviewFeaturesInstructions')}</li>
            <li><strong>4. {t('continueInstructions')}</strong></li>
            </ul>}
      </div>

      <div className='mb-3'>
        {!autoSelect &&
          <>
            <label htmlFor='objectType' className='form-label'>{t('objectType')}</label>
            <div className='form-select-wrapper'>
              <select
                id='objectType'
                className='form-select'
                value={objectType}
                onChange={(e) => setObjectType(e.target.value)}
                disabled={autoSelect}
              >
                <option value='lithics'>{t('lithics')}</option>
                <option value='grave'>{t('graves')}</option>
                <option value='arrowheads'>{t('arrowheads')}</option>
                <option value='ceramics'>{t('ceramics')}</option>
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
                  src={demoImage}
                  alt={t('demoFile')}
                  className='source-image img-fluid'
                />
                )
              : (
                <div className='source-placeholder'>
                  <span className='source-icon'>🖼️</span>
                  <span className='source-text'>{t('demoFile')}</span>
                </div>
                )}
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
              <span className='dropzone-text'>
                {isDragOver ? 'Drop the file here...' : autoSelect ? t('dragImage') : t('dragDrop')}
              </span>
              <span className='dropzone-hint'> {t('orClick')}</span>
            </label>
          </div>
          {demoImage === null &&
            <div className='dropzone-help'>
              <span className='help-item'>🖼️ {t('supports')} JPG, PNG, GIF, WebP</span>
              <span className='help-item'>⏱️ {t('max')} 10MB</span>
            </div>}
        </div>
      </div>

      {file && (
        <ul className='file-list'>
          <li>{autoSelect ? 'page_image.jpg' : file.name}</li>
        </ul>
      )}

      <div className='next-button-area'>
        <SharedButton
          type='button'
          disabled={!isFileSet}
          onClick={handleNext}
        >
          <span>{t('continue')}</span>
          <span style={{ display: isFileSet ? 'none' : 'inline' }}>{`(${t('selectFile')})`}</span>
        </SharedButton>
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
