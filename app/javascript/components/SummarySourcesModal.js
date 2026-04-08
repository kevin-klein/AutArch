import React, { useState, useEffect } from 'react'
// import { Modal, Button } from 'react-bootstrap';

const SummarySourcesModal = ({ figureId, figureType }) => {
  const [show, setShow] = useState(false)
  const [summary, setSummary] = useState('')
  const [sources, setSources] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchSummarySources = async () => {
    try {
      setLoading(true)
      setError(null)

      let url
      if (figureType === 'Grave') {
        url = `/graves/${figureId}/update_grave/show_summary_sources`
      } else {
        url = `/size_figures/${figureId}/update_size_figure/show_summary_sources`
      }

      const response = await fetch(url, {
        headers: {
          Accept: 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch summary sources')
      }

      const data = await response.json()

      if (data.error) {
        throw new Error(data.error)
      }

      setSummary(data.summary)
      setSources(data.sources || [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const renderContent = () => {
    if (loading) {
      return <p>Loading...</p>
    }

    if (error) {
      return <p className='text-danger'>{error}</p>
    }

    return (
      <div>
        <h6>Summary:</h6>
        <p>{summary}</p>

        {sources.length > 0 && (
          <div>
            <h6>Sources:</h6>
            <ul>
              {sources.map((source, index) => (
                <li key={index}>Page {source.page_number}</li>
              ))}
            </ul>
          </div>
        )}
      </div>
    )
  };

  const handleShow = () => {
    setShow(true)
    fetchSummarySources()
  };

  const handleClose = () => {
    setShow(false)
  };

  return (
    <>
      <button className='btn btn-info mt-2' onClick={handleShow}>
        Show Summary Sources
      </button>

      <Modal show={show} onHide={handleClose} size='lg'>
        <Modal.Header closeButton>
          <Modal.Title>Summary Sources</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {renderContent()}
        </Modal.Body>
        <Modal.Footer>
          <Button variant='secondary' onClick={handleClose}>
            Close
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
};

export default SummarySourcesModal
