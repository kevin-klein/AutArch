import React, { useState, useEffect, useRef } from 'react'
import UploadStep from './arrowheads/UploadStep'
import SelectCeramic from './SelectCeramic'
import SimilarityStep from './arrowheads/SimilarityStep'
import { createIdleTimer } from '../utils/idleTimer'

export default function CeramicWizard ({ page = null, options = {} }) {
  const [currentStep, setCurrentStep] = useState(0)
  const [wizard, setWizard] = useState(null)
  const [uploading, setUploading] = useState(false)
  const [image, setImage] = useState(null)
  const [imageFile, setImageFile] = useState(null)
  const [boxes, setBoxes] = useState([])
  const [finalBoxes, setFinalBoxes] = useState([])
  const [ceramics, setCeramics] = useState([])
  const [newBoxPoints, setNewBoxPoints] = useState([])
  const [isCreatingNewBox, setIsCreatingNewBox] = useState(false)
  const [selectedBoxId, setSelectedBoxId] = useState(null)
  const [samPoints, setSamPoints] = useState({})
  const [objectType, setObjectType] = useState('Ceramics')
  const [loading, setLoading] = useState(false)

  const divRef = useRef(null)
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 })
  const [stageScale, setStageScale] = useState(1)

  // Get timeout from config or use default 60s
  const idleTimeout = options.idleTimeout || 60000

  // Initialize dimensions based on container
  useEffect(() => {
    if (divRef.current && image) {
      const width = divRef.current.offsetWidth
      const height = (width / image.width) * image.height
      setDimensions({ width, height })
      setStageScale(width / image.width)
    }
  }, [image])

  // Initialize wizard on load
  useEffect(() => {
    initWizard()
  }, [page])

  // Initialize wizard
  const initWizard = async () => {
    try {
      setUploading(true)
      const response = await fetch('/analysis_wizards', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ page_id: page?.id })
      })

      if (response.ok) {
        const data = await response.json()
        setWizard(data.id)
      }
    } catch (err) {
      console.error('Failed to create wizard:', err)
    } finally {
      setUploading(false)
    }
  }

  // Reset wizard on idle
  const handleIdle = () => {
    // console.log('Wizard idle - resetting to beginning')
    // setCurrentStep(0)
    // setBoxes([])
    // setFinalBoxes([])
    // setCeramics([])
    // setImage(null)
    // setImageFile(null)
    // setSamPoints({})
    // setWizard(null)
  }

  // Setup idle timer
  useEffect(() => {
    const { reset, stop } = createIdleTimer(handleIdle, idleTimeout)

    return () => {
      stop()
    }
  }, [idleTimeout])

  // Step 1: Upload and detect objects
  const goNextWithObjectType = async (file, objectType) => {
    // if (file) {
    //   const imageUrl = URL.createObjectURL(file)
    //   const imageObject = new Image()
    //   imageObject.src = imageUrl
    //   setImage(imageObject)
    //   setImageFile(file)
    //   setObjectType(objectType)
    //   setUploading(true)
    //   try {
    //     await uploadImage(file, objectType)
    //   } catch (e) {
    //     console.error(e)
    //   }
    setCurrentStep((s) => s + 1)
    // }
  }

  const uploadImage = async (file, objectType) => {
    try {
      const formData = new FormData()
      formData.append('image', file)
      formData.append('object_type', objectType)

      const response = await fetch('/size_figures/boxes', {
        method: 'POST',
        body: formData
      })

      if (!response.ok) throw new Error('Upload failed')

      const result = await response.json()
      setBoxes(result.boxes || [])
      setCurrentStep((s) => s + 1)
    } finally {
      setUploading(false)
    }
  }

  // Get page image data for automatic upload
  const getPageImageData = () => {
    if (page?.image?.data) {
      return page.image.data
    }
    // For kiosk mode, read demo.jpg from public folder
    return fetch('/demo.jpg')
      .then(response => {
        if (!response.ok) throw new Error('Failed to load demo image')
        return response.arrayBuffer()
      })
      .then(buffer => {
        return new Uint8Array(buffer)
      })
      .catch(err => {
        console.error('Failed to load demo image:', err)
        return null
      })
  }

  // Read demo.jpg for kiosk mode
  const [pageImageData, setPageImageData] = useState(null)

  useEffect(() => {
    const loadData = async () => {
      if (!page?.image?.data) {
        const data = await getPageImageData()
        if (data) {
          setPageImageData(data)
          console.log('Loaded demo.jpg for kiosk mode')
        }
      }
    }
    loadData()
  }, [page])

  // Fallback to page image data if available
  const effectiveImageData = page?.image?.data || pageImageData

  // Step 2: Contour refinement
  const handleContoursComplete = async (updatedBoxes) => {
    if (!imageFile || updatedBoxes.length === 0) return

    setLoading(true)
    try {
      const formData = new FormData()
      formData.append('image', imageFile)
      formData.append('boxes', JSON.stringify(updatedBoxes))

      const response = await fetch('/analysis_wizards/step_1', {
        method: 'POST',
        body: formData
      })

      if (!response.ok) throw new Error('Contour processing failed')

      const result = await response.json()
      setFinalBoxes(updatedBoxes)
      setBoxes(updatedBoxes)
      setCurrentStep((s) => s + 1)
    } catch (err) {
      console.error('Error processing contours:', err)
      alert('Failed to process contours')
    } finally {
      setLoading(false)
    }
  }

  // Step 3: Similarity
  const handleSimilarityComplete = async (ceramicIds) => {
    setFinalBoxes([...finalBoxes, ...ceramicIds])
    setCurrentStep((s) => 3)
  }

  const goBack = () => setCurrentStep((s) => Math.max(0, s - 1))

  const steps = [
    <UploadStep
      key='upload'
      onNext={(file, objectType) => goNextWithObjectType(file, objectType)}
      autoSelect={true}
      fixedImage={effectiveImageData}
      demoImage={pageImageData}
      fixedObjectType='Ceramics'
    />,
    <SelectCeramic
      key='contour'
      boxes={boxes}
      image={image}
      imageFile={imageFile}
      label="Ceramic"
      onNext={handleContoursComplete}
      onBack={goBack}
      isWizard={true}
      setBoxes={setBoxes}
    />,
    <SimilarityStep
      key='similarity'
      boxes={finalBoxes}
      image={image}
      imageFile={imageFile}
      wizardId={wizard}
      figureId={finalBoxes[0]}
      onNext={handleSimilarityComplete}
      onBack={goBack}
    />
  ]

  if (uploading && !image) {
    return <div className="loading-wizard">Initializing Wizard...</div>
  }

  return (
    <div className='ceramic-wizard'>
      {currentStep < 3 && (
        <>
          <h1 style={{textAlign: 'center'}}>AutArch</h1>
          <h2>Step {currentStep + 1} of 3</h2>
        </>
      )}

      {currentStep === 2 && (
        <div className='alert alert-info mb-3'>
          <h5>Completing Analysis</h5>
          <p>Your ceramic analysis is being completed.</p>
        </div>
      )}

      {steps[currentStep]}
    </div>
  )
}
