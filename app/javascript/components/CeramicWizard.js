import React, { useState, useEffect, useRef } from 'react'
import UploadStep from './arrowheads/UploadStep'
import SelectCeramic from './SelectCeramic'
import SimilarityStep from './arrowheads/SimilarityStep'
import LanguageSelection from './LanguageSelection'
import useIdle, { reloadPage } from '../utils/idleTimer'
import { t } from '../utils/i18n'
import useImage from 'use-image'

export default function CeramicWizard ({ kioskConfig, options = {} }) {
  const [currentStep, setCurrentStep] = useState(0)
  const [figure, setFigure] = useState(null)
  const [language, setLanguage] = useState(null)

  // Get timeout from config or use default 60s
  const idleTimeout = options.idleTimeout || 60000

  useIdle(() => {
    reloadPage()
  }, idleTimeout)

  const handleLanguageSelect = (langCode) => {
    setLanguage(langCode)
  }

  const goNext = () => {
    setCurrentStep((s) => s + 1)
  }

  const goNextWithFigure = (figure) => {
    setFigure(figure)
    setCurrentStep((s) => s + 1)
  }

  const goBack = () => setCurrentStep((s) => Math.max(0, s - 1))

  const steps = [
    <UploadStep
      key='upload'
      onNext={(file, objectType) => goNext(file, objectType)}
      autoSelect
      fixedImage
      demoImage={kioskConfig.image}
      fixedObjectType='Ceramics'
    />,
    <SelectCeramic
      key='contour'
      onBack={goBack}
      figuresData={kioskConfig}
      isWizard
      onNext={goNextWithFigure}
    />,
    <SimilarityStep
      key='similarity'
      figure={figure}
      goBack={goBack}
      figuresData={{
        ...kioskConfig,
        three_d_model: kioskConfig.three_d_model || kioskConfig.preview_image
      }}
    />
  ]

  // Show language selection first
  if (!language) {
    return <LanguageSelection onLanguageSelect={handleLanguageSelect} />
  }

  return (
    <div className='ceramic-wizard'>
      {currentStep < 3 && (
        <>
          <h1 style={{ textAlign: 'center' }}>AutArch</h1>
          <h2>{t('step')} {currentStep + 1} {t('of')} 3</h2>
        </>
      )}

      {steps[currentStep]}
    </div>
  )
}
