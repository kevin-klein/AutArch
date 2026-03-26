import React, { useState, useEffect } from 'react'
import LoadingDialog from './LoadingDialog'

export default function SimilarityStep ({ boxes = [], image, imageFile, wizardId, figureId }) {
  const [similarCeramics, setSimilarCeramics] = useState([])
  const [loading, setLoading] = useState(false)
  const [currentFigure, setCurrentFigure] = useState(null)

  const fetchSimilarCeramics = async () => {
    if (!wizardId) return

    setLoading(true)
    try {
      const response = await fetch(`/analysis_wizards/${wizardId}/similar_ceramics?figure_id=${figureId}`)
      const data = await response.json()
      setCurrentFigure(data.figure)
      setSimilarCeramics(data.similar_ceramics || [])
    } catch (err) {
      console.error('Failed to fetch similar ceramics:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchSimilarCeramics()
  }, [wizardId, figureId])

  if (loading) {
    return <LoadingDialog />
  }

  const topSimilarity = similarCeramics.length > 0 ? similarCeramics[0].similarity : 0

  return (
    <div className='row'>
      {/* Left side - Similar Ceramics */}
      <div className='col-md-6'>
        <div className='card'>
          <div className='card-header'>
            <h5 className='mb-0'>Most Similar Ceramics</h5>
          </div>
          <div className='card-body'>
            {similarCeramics.length === 0
              ? (
                <div className='text-center text-muted'>
                  <p>No similar ceramics found in this publication.</p>
                </div>
                )
              : (
                <div>
                  <p className='mb-3'>
                    Top Similarity: <strong>{(topSimilarity * 100).toFixed(1)}%</strong>
                  </p>
                  <div className='grid'>
                    {similarCeramics.map((ceramic, idx) => (
                      <div key={ceramic.ceramic_id || idx} className='similarity-card'>
                        <div className='similarity-content'>
                          {ceramic.image && (
                            <div className='similarity-image'>
                              <img
                                src={ceramic.image}
                                alt={ceramic.name}
                                className='card-image'
                              />
                            </div>
                          )}
                          <div className='similarity-item'>
                            <strong>#{idx + 1} {ceramic.name}</strong>
                          </div>
                          <div className='similarity-item'>
                            <span className='similarity-badge'>
                              {(ceramic.similarity * 100).toFixed(1)}% Similarity
                            </span>
                          </div>
                          {ceramic.description && (
                            <div className='similarity-item'>
                              <small>{ceramic.description}</small>
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                  <div className='mt-3 text-center text-muted'>
                    <small>Compared with {similarCeramics.length} other ceramics from the same publication</small>
                  </div>
                </div>
                )}
          </div>
        </div>
      </div>

      {/* Right side - Analysis Details */}
      <div className='col-md-6'>
        <div className='card'>
          <div className='card-header'>
            <h5 className='mb-0'>Analysis Details</h5>
          </div>
          <div className='card-body'>
            <h6>Bag of Visual Words (BOVW)</h6>
            <div className='feature-list'>
              <div className='feature-item'>
                <span className='feature-icon'>🔍</span>
                <span className='feature-text'>
                  Feature Extraction: Extracts 128-dimensional visual features from ceramic image
                </span>
              </div>
              <div className='feature-item'>
                <span className='feature-icon'>📊</span>
                <span className='feature-text'>
                  Similarity Calculation: Cosine similarity comparing BOVW feature vectors across publication
                </span>
              </div>
              <div className='feature-item'>
                <span className='feature-icon'>🎯</span>
                <span className='feature-text'>
                  Pattern Recognition: Identifies visually similar ceramics based on shape and texture
                </span>
              </div>
              <div className='feature-item'>
                <span className='feature-icon'>📁</span>
                <span className='feature-text'>
                  Publication Scope: Compares against all ceramics in the same publication
                </span>
              </div>
              <div className='feature-item'>
                <span className='feature-icon'>💾</span>
                <span className='feature-text'>
                  Data Persistence: Features stored in database for future analysis
                </span>
              </div>
            </div>

            <hr />

            <div className='analysis-summary'>
              <h6>Extracted Features</h6>
              {currentFigure && (
                <div className='features-grid'>
                  <div className='feature-column'>
                    <strong>128</strong>
                    <span>Feature Dimensions</span>
                  </div>
                  <div className='feature-column'>
                    <strong>{similarCeramics.length}</strong>
                    <span>Similar Ceramics Found</span>
                  </div>
                  <div className='feature-column'>
                    <strong>{similarCeramics.length > 0 ? (similarCeramics[0].similarity * 100).toFixed(1) : 0}</strong>
                    <span>Top Similarity</span>
                  </div>
                </div>
              )}
              {!currentFigure && (
                <p className='text-muted'>No analysis data available</p>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className='col-12'>
        <div className='d-flex justify-content-between mt-3'>
          <button className='btn btn-secondary'>Back</button>
          <button className='btn btn-primary'>
            Complete Analysis
          </button>
        </div>
      </div>
    </div>
  )
}
