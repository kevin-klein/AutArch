import React, { useState, useEffect } from 'react'
import { createRoot } from 'react-dom/client'
import PropTypes from 'prop-types'
import useSWR from 'swr'

const fetcher = (...args) => fetch(...args).then(res => {
  if (!res.ok) {
    throw new Error(`HTTP error! status: ${res.status}`)
  }
  return res.json()
})

// Figure type badge colors
const figureTypeColors = {
  Grave: 'figure-type-grave',
  Arrow: 'figure-type-arrow',
  Ceramic: 'figure-type-ceramic',
  StoneTool: 'figure-type-stonetool',
  Skeleton: 'figure-type-skeleton',
  Kurgan: 'figure-type-kurgan',
  Oxcal: 'figure-type-oxcal',
  Bone: 'figure-type-bone',
  default: 'figure-type-default'
}

function KioskConfig ({ kioskConfig = null, options = {} }) {
  const [selectedPublicationId, setSelectedPublicationId] = useState(null)
  const [selectedPageId, setSelectedPageId] = useState(null)
  const [selectedFigureId, setSelectedFigureId] = useState(null)
  const [error, setError] = useState(null)

  const saveLoading = false

  const { data: publications, errorLoadingPublications: publicationsError, isLoading: loadingPublications } = useSWR(
    '/kiosk_configs/publications.json',
    fetcher
  )

  const { data: pages, errorLoadingPublications: pagesError, isLoading: loadingPages } = useSWR(
    selectedPublicationId !== null ? `/kiosk_configs/pages.json?publication_id=${selectedPublicationId}` : null,
    fetcher
  )

  const { data: figures, errorLoadingPublications: figuresError, isLoading: loadingFigures } = useSWR(
    selectedPageId !== null ? `/kiosk_configs/kiosk_config/pages/${selectedPageId}/figures.json` : null,
    fetcher
  )

  const selectedFigure = figures !== undefined ? figures.find(f => f.id === selectedFigureId) : null

  React.useEffect(() => {
    loadCurrentConfig()
  }, [])

  const loadCurrentConfig = async () => {
    try {
      const response = await fetch('/kiosk_configs/kiosk_config.json')
      const config = await response.json()

      if (response.ok && config?.page_id && config?.figure_id) {
        setSelectedPublicationId(config.publication_id)
        setSelectedPageId(config.page_id)
        setSelectedFigureId(config.figure_id)

        // Auto-select in dropdowns
        // const publicationOption = publications.find(p => p.id === config.page_id)

        // if (publicationOption) {
        //   setSelectedPublication(publicationOption)
        //   await loadPageFigures(config.page_id)
        // }

        // const figureOption = figures.find(f => f.id === config.figure_id)

        // if (figureOption) {
        //   setSelectedFigureId(config.figure_id)
        //   updatePreview(figureOption)
        // }
      }
    } catch (err) {
      console.error('Error loading current config:', err)
    }
  }

  // Load figures for selected page
  const loadPageFigures = async (pageId) => {
    setLoading(prev => ({ ...prev, figures: true }))
    setError(null)

    try {
      const response = await fetch(`/kiosk_configs/kiosk_config/pages/${pageId}/figures.json`)
      const figures = await response.json()

      if (response.ok && Array.isArray(figures)) {
        setCurrentPageFigures(figures)
      } else {
        setError('Failed to load figures')
      }
    } catch (err) {
      console.error('Error loading figures:', err)
      setError('Error loading figures')
    } finally {
      setLoading(prev => ({ ...prev, figures: false }))
    }
  }

  // Handle publication selection
  const handlePublicationChange = async (e) => {
    const id = parseInt(e.target.value)
    setSelectedPublicationId(id)
    setSelectedPageId(null)
    setSelectedFigureId(null)
  }

  // Handle figure selection
  const handleFigureChange = (e) => {
    const figureId = parseInt(e.target.value)
    setSelectedFigureId(figureId)
  }

  // Handle save configuration
  const handleSave = async (e) => {
    e.preventDefault()
    setError(null)

    try {
      const response = await fetch('/kiosk_configs/kiosk_config.json', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
        },
        body: JSON.stringify({
          kiosk_config: {
            page_id: selectedPageId,
            figure_id: selectedFigureId
          }
        })
      })

      const result = await response.json()

      if (response.ok && result.success) {
        alert('Kiosk configuration saved successfully!')

        // Re-load current config to ensure sync
        // await loadCurrentConfig()
      } else {
        setError('Error saving configuration: ' + (result.errors?.join(', ') || 'Unknown error'))
      }
    } catch (err) {
      console.error('Error saving configuration:', err)
      setError('Error saving configuration: ' + err.message)
    } finally {
      // setLoading(prev => ({ ...prev, save: false }))
    }
  }

  function handlePageChange (e) {
    setSelectedPageId(parseInt(e.target.value))
  }

  return (
    <div className='kiosk-config-container'>
      <div className='row'>
        <div className='col-lg-5'>
          <div className='card mb-4'>
            <div className='card-header bg-primary text-white'>
              <h5 className='mb-0'><i className='bi bi-gear' /> Configure Kiosk</h5>
            </div>
            <div className='card-body'>
              <form>
                <div className='mb-3'>
                  <label htmlFor='publicationSelect' className='form-label'>
                    <i className='bi bi-book' /> Select Publication
                  </label>
                  <select
                    id='publicationSelect'
                    className='form-select'
                    required
                    disabled={loadingPublications}
                    value={selectedPublicationId ?? ''}
                    onChange={handlePublicationChange}
                  >
                    <option value=''>-- Select a publication --</option>
                    {loadingPublications
                      ? (
                        <option value='' disabled>Loading publications...</option>
                        )
                      : (
                          publications.map((item, index) => (
                            <option key={index} value={item.id}>
                              {item.title || 'Untitled'} - {item.author} {item.year}
                            </option>
                          ))
                        )}
                  </select>
                </div>

                <div className='mb-3'>
                  <label htmlFor='pageSelect' className='form-label'>
                    <i className='bi bi-file-text' /> Select Page
                  </label>
                  <select
                    id='pageSelect'
                    className='form-select'
                    required
                    disabled={loadingPages || selectedPublicationId === null}
                    value={selectedPageId ?? ''}
                    onChange={handlePageChange}
                  >
                    <option value=''>-- Select a publication first --</option>
                    {(loadingPages || pages === undefined)
                      ? (
                        <option value='' disabled>Loading pages...</option>
                        )
                      : (
                          pages.map(page => (
                            <option key={page.id} value={page.id}>
                              {page.number + 1}
                            </option>
                          ))
                        )}
                  </select>
                </div>

                <div className='mb-3'>
                  <label htmlFor='pageSelect' className='form-label'>
                    <i className='bi bi-file-text' /> Select Figure
                  </label>
                  <select
                    id='pageSelect'
                    className='form-select'
                    required
                    disabled={loadingFigures || selectedPublicationId === null}
                    value={selectedFigureId ?? ''}
                    onChange={handleFigureChange}
                  >
                    <option value=''>-- Select a publication first --</option>
                    {(loadingPages || figures === undefined)
                      ? (
                        <option value='' disabled>Loading figures...</option>
                        )
                      : (
                          figures.map(figure => (
                            <option key={figure.id} value={figure.id}>
                              {figure.id} - {figure.type}
                            </option>
                          ))
                        )}
                  </select>
                </div>

                <div className='d-grid gap-2'>
                  <button
                    type='submit'
                    className='btn btn-primary'
                    disabled={saveLoading || !selectedFigureId}
                    onClick={handleSave}
                  >
                    {saveLoading
                      ? (
                        <span>
                          <span className='spinner-border spinner-border-sm me-2' role='status' aria-hidden='true' />
                          Saving...
                        </span>
                        )
                      : (
                        <><i className='bi bi-save' /> Save Configuration</>
                        )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <div className='col-lg-7'>
          <div className='card mb-4'>
            <div className='card-header bg-success text-white'>
              <h5 className='mb-0'><i className='bi bi-eye' /> Figure Preview</h5>
            </div>
            <div className='card-body'>
              {error && (
                <div className='alert alert-danger' role='alert'>
                  {error}
                </div>
              )}

              {selectedFigure && (
                <div className='figure-info mt-3'>
                  <h6 className='mb-3'>Figure Details</h6>
                  <div className='row'>
                    <div className='col-md-12'>
                      <p><strong>Type:</strong>
                        <img className='img img-fluid' src={selectedFigure.image_url} />
                      </p>
                    </div>
                    <div className='col-md-6'>
                      <p><strong>Type:</strong>
                        <span className={`figure-type-badge figure-type-${selectedFigure.type.toLowerCase()}`}>
                          {selectedFigure.type}
                        </span>
                      </p>
                    </div>
                    <div className='col-md-6'>
                      <p><strong>Identifier:</strong>
                        <span className='ms-2'>{selectedFigure.identifier}</span>
                      </p>
                    </div>
                  </div>
                  <div className='row mt-2'>
                    <div className='col-md-4'>
                      <p><strong>Probability:</strong>
                        <span className='ms-2'>{selectedFigure.probability}</span>
                      </p>
                    </div>
                    <div className='col-md-4'>
                      <p><strong>X1:</strong>
                        <span className='ms-2'>{selectedFigure.x1}</span>
                      </p>
                    </div>
                    <div className='col-md-4'>
                      <p><strong>Y1:</strong>
                        <span className='ms-2'>{selectedFigure.y1}</span>
                      </p>
                    </div>
                  </div>
                  <div className='row mt-2'>
                    <div className='col-md-4'>
                      <p><strong>X2:</strong>
                        <span className='ms-2'>{selectedFigure.x2}</span>
                      </p>
                    </div>
                    <div className='col-md-4'>
                      <p><strong>Y2:</strong>
                        <span className='ms-2'>{selectedFigure.y2}</span>
                      </p>
                    </div>
                    <div className='col-md-4'>
                      <p><strong>Area:</strong>
                        <span className='ms-2'>{selectedFigure.area}</span>
                      </p>
                    </div>
                  </div>
                  <div className='row mt-2'>
                    <div className='col-12'>
                      <p><strong>Page:</strong>
                        <span className='ms-2'>{selectedFigure.page}</span>
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className='card'>
            <div className='card-header bg-info text-white'>
              <h5 className='mb-0'><i className='bi bi-info' /> Instructions</h5>
            </div>
            <div className='card-body'>
              <ol>
                <li><strong>Select a Publication</strong> from the dropdown</li>
                <li><strong>Select a Page</strong> from the second dropdown</li>
                <li><strong>Select a Figure</strong> from the third dropdown</li>
                <li>Review the figure preview and details below</li>
                <li><strong>Save the Configuration</strong> using the button</li>
              </ol>
              <div className='alert alert-warning'>
                <i className='bi bi-exclamation-triangle' />
                <strong>Note:</strong> Only public publications and figures with high confidence (probability more than 0.6) can be selected.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

KioskConfig.propTypes = {
  kioskConfig: PropTypes.object,
  options: PropTypes.object
}

// Mount the component
document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('kiosk-config-root')

  if (container) {
    const props = container.dataset

    createRoot(container).render(
      <KioskConfig
        kioskConfig={JSON.parse(props.kioskConfig || 'null')}
        options={JSON.parse(props.options || '{}')}
      />
    )
  }
})

export default KioskConfig
