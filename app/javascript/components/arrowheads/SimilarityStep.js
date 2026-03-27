import React, { useState, useEffect, useMemo } from 'react'
import LoadingDialog from './LoadingDialog'
import useSWR from 'swr'
import PLYViewer from '../PLYViewer'
import SharedButton from '../SharedButton'
import { reloadPage } from '../../utils/idleTimer'
import { t } from '../../utils/i18n'

const fetcher = (...args) => fetch(...args).then(res => {
  if (!res.ok) {
    throw new Error(`HTTP error! status: ${res.status}`)
  }
  return res.json()
})

// Similarity Item Component
function SimilarityItem ({ ceramic, index, isSelected, onClick }) {
  const similarityPercent = (ceramic.similarity * 100).toFixed(1)

  let similarityColor
  let similarityLabel
  let gradientBg

  if (ceramic.similarity >= 0.8) {
    similarityColor = '#10b981' // Emerald - high similarity
    similarityLabel = t('verySimilar')
    gradientBg = 'linear-gradient(135deg, #10b981 0%, #059669 100%)'
  } else if (ceramic.similarity >= 0.6) {
    similarityColor = '#f59e0b' // Amber - medium similarity
    similarityLabel = t('moderatelySimilar')
    gradientBg = 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)'
  } else {
    similarityColor = '#ef4444' // Red - low similarity
    similarityLabel = t('lessSimilar')
    gradientBg = 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)'
  }

  return (
    <div
      className={`similarity-item ${isSelected ? 'selected' : ''}`}
      onClick={() => onClick(ceramic)}
      style={{
        padding: '20px',
        backgroundColor: isSelected ? '#f0f9ff' : 'white',
        border: isSelected ? '2px solid #3b82f6' : '1px solid #e5e7eb',
        borderRadius: '12px',
        cursor: 'pointer',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        boxShadow: isSelected
          ? '0 8px 24px rgba(59, 130, 246, 0.25)'
          : '0 2px 8px rgba(0, 0, 0, 0.08)',
        transform: isSelected ? 'scale(1.02)' : 'scale(1)',
        position: 'relative',
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        minHeight: '140px'
      }}
    >
      {/* Selection indicator bar */}
      {isSelected && (
        <div style={{
          position: 'absolute',
          left: 0,
          top: 0,
          bottom: 0,
          width: '4px',
          backgroundColor: '#3b82f6'
        }}
        />
      )}

      {/* Top row: Image and info on left, similarity on right */}
      <div style={{
        display: 'flex',
        gap: '16px',
        alignItems: 'flex-start',
        marginBottom: '12px'
      }}
      >
        {/* Ceramic Image */}
        <div style={{
          width: '90px',
          height: '90px',
          borderRadius: '10px',
          overflow: 'hidden',
          flexShrink: 0,
          border: '1px solid #e5e7eb',
          backgroundColor: '#f9fafb'
        }}
        >
          <img
            src={`/figures/${ceramic.id}/preview`}
            alt={ceramic.identifier}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover'
            }}
          />
        </div>

        {/* Info - flex to fill space */}
        <div style={{
          flex: 1,
          minWidth: 0,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center'
        }}
        >
          <div style={{
            fontWeight: '700',
            fontSize: '16px',
            color: '#111827',
            marginBottom: '4px',
            lineHeight: '1.3'
          }}
          >
            {ceramic.identifier}
          </div>

          {/* Site and page info - always present, consistent spacing */}
          <div style={{
            fontSize: '13px',
            color: '#6b7280',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            marginBottom: '2px'
          }}
          >
            {ceramic.site && (
              <>
                <span style={{ fontSize: '13px' }}>📍</span>
                <span>{ceramic.site.name}</span>
              </>
            )}
            {!ceramic.site && <span style={{ opacity: 0.3 }}>&nbsp;</span>}
          </div>

          <div style={{
            fontSize: '12px',
            color: '#9ca3af',
            display: 'flex',
            alignItems: 'center',
            gap: '6px'
          }}
          >
            <span>{t('page')} {ceramic.page_number}</span>
            <span>{t('ceramics')} {ceramic.identifier}</span>
          </div>
        </div>

        {/* Right side: Similarity info */}
        <div style={{
          flexShrink: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-end',
          justifyContent: 'center',
          minWidth: '120px'
        }}
        >
          {/* Percentage */}
          <div style={{
            fontSize: '26px',
            fontWeight: '800',
            background: gradientBg,
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
            marginBottom: '6px'
          }}
          >
            {similarityPercent}%
          </div>

          {/* Label badge */}
          <div style={{
            fontSize: '11px',
            color: 'white',
            backgroundColor: similarityColor,
            padding: '3px 10px',
            borderRadius: '12px',
            display: 'inline-block',
            fontWeight: '600',
            boxShadow: `0 2px 6px ${similarityColor}40`
          }}
          >
            {similarityLabel}
          </div>
        </div>
      </div>

      {/* Similarity Progress Bar */}
      <div style={{
        height: '5px',
        backgroundColor: '#f3f4f6',
        borderRadius: '3px',
        overflow: 'hidden'
      }}
      >
        <div style={{
          width: `${similarityPercent}%`,
          height: '100%',
          background: gradientBg,
          borderRadius: '3px',
          transition: 'width 0.5s cubic-bezier(0.4, 0, 0.2, 1)'
        }}
        />
      </div>
    </div>
  )
}

export default function SimilarityStep ({ figure, goBack, figuresData }) {
  const { data: similarity, error: similarityError, isLoading: loadingSimilarity } = useSWR(
    `/ceramics/${figure.id}/similarities.json`,
    fetcher
  )

  const [selectedCeramic, setSelectedCeramic] = useState(null)
  const [showPreview, setShowPreview] = useState(false)

  // Get 3D model URL from figuresData
  const threeDModelUrl = figuresData?.three_d_model || figuresData?.preview_image

  const handleCeramicClick = (ceramic) => {
    setSelectedCeramic(ceramic)
    setShowPreview(true)
  }

  const handleClosePreview = () => {
    setShowPreview(false)
  }

  if (loadingSimilarity) {
    return (
      <div style={{ textAlign: 'center', padding: '50px' }}>
        <LoadingDialog message={t('loading')} />
      </div>
    )
  }

  if (similarityError) {
    return (
      <div style={{ textAlign: 'center', padding: '50px', color: '#dc3545' }}>
        <h3>{t('errorLoadingSimilarities')}</h3>
        <p>{similarityError.message}</p>
        <button
          onClick={goBack}
          style={{
            marginTop: '20px',
            padding: '10px 20px',
            backgroundColor: '#6c757d',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          {t('back')}
        </button>
      </div>
    )
  }

  if (!similarity) {
    return (
      <div style={{ textAlign: 'center', padding: '50px', color: '#6c757d' }}>
        <h3>{t('noSimilarityData')}</h3>
        <p>{t('similarityDataNotComputed')}</p>
        <button
          onClick={goBack}
          style={{
            marginTop: '20px',
            padding: '10px 20px',
            backgroundColor: '#6c757d',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          {t('back')}
        </button>
      </div>
    )
  }

  return (
    <div className='similarity-step'>
      <style>{`
        .similarity-step {
          padding: 32px 24px;
          max-width: 1600px;
          margin: 0 auto;
          background: linear-gradient(180deg, #f8fafc 0%, #ffffff 100%);
          min-height: 100vh;
        }

        /* Header Section */
        .similarity-header {
          text-align: center;
          margin-bottom: 40px;
          padding: 32px 24px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 20px;
          color: white;
          box-shadow: 0 10px 40px rgba(102, 126, 234, 0.3);
        }

        .similarity-header h2 {
          font-size: 36px;
          font-weight: 800;
          margin: 0 0 12px 0;
          letter-spacing: -0.5px;
          text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .similarity-header p {
          font-size: 18px;
          margin: 0;
          opacity: 0.95;
          font-weight: 400;
        }

        /* Controls Bar */
        .similarity-controls {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 32px;
          padding: 24px 28px;
          background: white;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
          border: 1px solid #e5e7eb;
        }

        .similarity-stats {
          display: flex;
          gap: 48px;
        }

        .stat-item {
          text-align: center;
          padding: 0 8px;
        }

        .stat-value {
          font-size: 32px;
          font-weight: 800;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
          margin-bottom: 4px;
        }

        .stat-label {
          font-size: 13px;
          color: #6b7280;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        /* Main Content Grid */
        .similarity-main {
          display: grid;
          grid-template-columns: 1fr 1.2fr;
          gap: 32px;
          margin-bottom: 32px;
        }

        /* Left Panel - Original Ceramic */
        .similarity-original {
          background: white;
          border-radius: 16px;
          padding: 28px;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
          border: 1px solid #e5e7eb;
          height: fit-content;
        }

        .similarity-original h3 {
          font-size: 20px;
          font-weight: 700;
          color: #1f2937;
          margin: 0 0 24px 0;
          padding-bottom: 16px;
          border-bottom: 2px solid #f3f4f6;
        }

        .original-image {
          width: 100%;
          border-radius: 12px;
          overflow: hidden;
          margin-bottom: 20px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .original-image img {
          width: 100%;
          display: block;
        }

        /* Right Panel - Similar Items */
        .similarity-right {
          display: flex;
          flex-direction: column;
        }

        .similarity-right h3 {
          font-size: 22px;
          font-weight: 700;
          color: #1f2937;
          margin: 0 0 20px 0;
          padding: 16px 20px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }

        .similarity-list {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
          gap: 16px;
          max-height: 700px;
          overflow-y: auto;
          padding-right: 12px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
          border: 1px solid #e5e7eb;
          padding: 16px;
        }

        .similarity-list::-webkit-scrollbar {
          width: 10px;
        }

        .similarity-list::-webkit-scrollbar-track {
          background: #f3f4f6;
          border-radius: 5px;
          margin: 4px 0;
        }

        .similarity-list::-webkit-scrollbar-thumb {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 5px;
        }

        .similarity-list::-webkit-scrollbar-thumb:hover {
          background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }

        /* Preview Modal */
        .preview-modal {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0, 0, 0, 0.75);
          backdrop-filter: blur(8px);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1000;
          padding: 24px;
          animation: fadeIn 0.2s ease;
        }

        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        .preview-content {
          background: white;
          border-radius: 20px;
          max-width: 1000px;
          max-height: 90vh;
          overflow-y: auto;
          padding: 40px;
          position: relative;
          box-shadow: 0 25px 80px rgba(0, 0, 0, 0.3);
          animation: slideUp 0.3s ease;
        }

        @keyframes slideUp {
          from {
            opacity: 0;
            transform: translateY(30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .close-preview {
          position: absolute;
          top: 20px;
          right: 20px;
          background: #6b7280;
          color: white;
          border: none;
          border-radius: 50%;
          width: 48px;
          height: 48px;
          font-size: 28px;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .close-preview:hover {
          background: #4b5563;
        }

        .preview-modal h2 {
          font-size: 28px;
          font-weight: 800;
          color: #1f2937;
          margin: 0 0 32px 0;
          padding-bottom: 16px;
          border-bottom: 3px solid #667eea;
        }

        .preview-images {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 24px;
          margin-bottom: 32px;
        }

        .preview-image-container {
          border-radius: 12px;
          overflow: hidden;
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
        }

        .preview-image-container img {
          width: 100%;
          display: block;
        }

        .preview-image-label {
          font-size: 14px;
          font-weight: 600;
          color: #6b7280;
          margin-bottom: 8px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .preview-details h4 {
          font-size: 20px;
          font-weight: 700;
          color: #1f2937;
          margin: 0 0 20px 0;
        }

        .detail-table {
          width: 100%;
          border-collapse: separate;
          border-spacing: 0;
        }

        .detail-table tr {
          border-bottom: 1px solid #e5e7eb;
        }

        .detail-table tr:last-child {
          border-bottom: none;
        }

        .detail-table td {
          padding: 16px;
          vertical-align: top;
        }

        .detail-table td:first-child {
          width: 140px;
          font-weight: 700;
          color: #4b5563;
          vertical-align: middle;
        }

        .detail-table td:last-child {
          color: #1f2937;
          font-weight: 500;
        }

        /* Responsive */
        @media (max-width: 1024px) {
          .similarity-main {
            grid-template-columns: 1fr;
          }

          .similarity-stats {
            gap: 24px;
          }
        }

        @media (max-width: 640px) {
          .similarity-step {
            padding: 16px 12px;
          }

          .similarity-header h2 {
            font-size: 24px;
          }

          .similarity-controls {
            flex-direction: column;
            gap: 16px;
            padding: 16px;
          }

          .similarity-stats {
            width: 100%;
            justify-content: space-around;
            gap: 16px;
          }

          .stat-value {
            font-size: 24px;
          }

          .similarity-list {
            grid-template-columns: 1fr;
          }

          .similarity-item {
            min-height: auto !important;
          }

          .preview-images {
            grid-template-columns: 1fr;
          }
        }
      `}
      </style>

      {/* Header */}
      <div className='similarity-header'>
        <h2>{t('similarityAnalysis')}</h2>
        <p>{t('comparingWith')} {similarity.ceramic.identifier} {t('withOtherVessels')}</p>
      </div>

      {/* Statistics Bar */}
      <div className='similarity-controls'>
        <SharedButton
          onClick={goBack}
          variant='secondary'
          style={{ width: 'auto', maxWidth: '300px', flexShrink: 0 }}
        >
          <span>←</span> {t('backToAnalysis')}
        </SharedButton>

        <SharedButton
          onClick={() => reloadPage()}
          style={{ width: 'auto', maxWidth: '300px', flexShrink: 0 }}
        >
          {t('nextAnalysis')}
        </SharedButton>

        <div className='similarity-stats'>
          <div className='stat-item'>
            <div className='stat-value'>{similarity.total_similar}</div>
            <div className='stat-label'>{t('similarVessels')}</div>
          </div>
          <div className='stat-item'>
            <div className='stat-value'>{similarity.publication.title}</div>
            <div className='stat-label'>{t('publication')}</div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className='similarity-main'>
        {/* Original Ceramic Panel */}
        <div className='similarity-original'>
          <h3>
            {t('originalVessel')}: {similarity.ceramic.identifier}
          </h3>
          <div className='original-image'>
            <img src={`/figures/${similarity.ceramic.id}/preview`} alt={similarity.ceramic.identifier} />
          </div>
          <PLYViewer
            modelUrl={threeDModelUrl}
            label={similarity.ceramic.identifier}
            width={400}
            height={400}
          />
        </div>

        {/* Similar Ceramics List */}
        <div className='similarity-right'>
          <h3>
            {t('similarVessels')} <span style={{ color: '#6b7280', fontWeight: 500 }}>({similarity.total_similar})</span>
          </h3>
          <div className='similarity-list'>
            {similarity.similarities.map((ceramic, index) => (
              <SimilarityItem
                key={ceramic.id}
                ceramic={ceramic}
                index={index}
                isSelected={selectedCeramic?.id === ceramic.id}
                onClick={handleCeramicClick}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Preview Modal */}
      {showPreview && selectedCeramic && (
        <div className='preview-modal' onClick={handleClosePreview}>
          <div className='preview-content' onClick={(e) => e.stopPropagation()}>
            <button className='close-preview' onClick={handleClosePreview}>×</button>

            <h2>
              {t('detailedComparison')}: {selectedCeramic.identifier}
            </h2>

            <div className='preview-images'>
              <div>
                <div className='preview-image-label'>{t('selectedCeramic')}</div>
                <div className='preview-image-container'>
                  <img src={`/figures/${selectedCeramic.id}/preview`} alt={selectedCeramic.identifier} />
                </div>
              </div>

              <div>
                <div className='preview-image-label'>{t('originalCeramic')}</div>
                <div className='preview-image-container'>
                  <img src={`/figures/${similarity.ceramic.id}/preview`} alt={similarity.ceramic.identifier} />
                </div>
              </div>
            </div>

            {/* Selected Ceramic Details */}
            <div className='preview-details'>
              <h4>{t('ceramicDetails')}</h4>
              <table className='detail-table'>
                <tbody>
                  <tr>
                    <td>{t('identifier')}</td>
                    <td>{selectedCeramic.identifier}</td>
                  </tr>
                  <tr>
                    <td>{t('similarityScore')}</td>
                    <td>
                      <span style={{
                        color: selectedCeramic.similarity >= 0.8
                          ? '#10b981'
                          : selectedCeramic.similarity >= 0.6 ? '#f59e0b' : '#ef4444',
                        fontWeight: '800',
                        fontSize: '20px'
                      }}
                      >
                        {(selectedCeramic.similarity * 100).toFixed(1)}%
                      </span>
                      <span style={{
                        marginLeft: '12px',
                        fontSize: '13px',
                        color: 'white',
                        backgroundColor: selectedCeramic.similarity >= 0.8
                          ? '#10b981'
                          : selectedCeramic.similarity >= 0.6 ? '#f59e0b' : '#ef4444',
                        padding: '4px 12px',
                        borderRadius: '20px',
                        fontWeight: '600'
                      }}
                      >
                        {selectedCeramic.similarity >= 0.8
                          ? t('verySimilar')
                          : selectedCeramic.similarity >= 0.6 ? t('moderatelySimilar') : t('lessSimilar')}
                      </span>
                    </td>
                  </tr>
                  <tr>
                    <td>{t('page')}</td>
                    <td>{t('page')} {selectedCeramic.page_number}</td>
                  </tr>
                  {selectedCeramic.site && (
                    <tr>
                      <td>{t('site')}</td>
                      <td>{selectedCeramic.site.name}</td>
                    </tr>
                  )}
                  <tr>
                    <td>{t('detectionConfidence')}</td>
                    <td>{(selectedCeramic.probability * 100).toFixed(1)}%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
