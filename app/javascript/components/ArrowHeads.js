import React, { useState, useRef, useEffect } from 'react'
import { Stage, Layer, Rect, Image as KonvaImage, Line, Circle as KonvaCircle } from 'react-konva'
import UploadStep from './arrowheads/UploadStep'
import Contours from './arrowheads/Contours'
import TableExport from './arrowheads/TableExport'

export default function () {
  const [currentStep, setCurrentStep] = useState(0)
  const [boxes, setBoxes] = useState([]) // boxes returned from /size_figures/boxes
  const [uploading, setUploading] = useState(false)
  const [image, setImage] = useState(null)
  const [imageFile, setImageFile] = useState(null)
  const [label, setLabel] = React.useState(null)
  const [finalBoxes, setFinalBoxes] = React.useState([])

  async function uploadImage (file, objectType) {
    const formData = new FormData()
    formData.append('image', file)
    formData.append('object_type', objectType)

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
  const goNext = async (boxes) => {
    setFinalBoxes(boxes)
    setCurrentStep((s) => s + 1)
  }

  const goNextWithObjectType = async (file, objectType) => {
    if (file) {
      const imageUrl = URL.createObjectURL(file)
      const imageObject = new Image()
      imageObject.src = imageUrl
      setImage(imageObject)
      setImageFile(file)
      setLabel(objectType)
      setUploading(true)
      try {
        const res = await uploadImage(file, objectType)
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
      onNext={(file, objectType) => goNextWithObjectType(file, objectType)}
    />,
    <Contours
      key='select'
      boxes={boxes}
      image={image}
      imageFile={imageFile}
      label={label}
      onNext={goNext}
      onBack={goBack}
    />,
    <TableExport
      key='export'
      boxes={finalBoxes}
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
