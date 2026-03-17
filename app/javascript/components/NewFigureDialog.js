import React from 'react'

export default function NewFigureDialog ({ closeDialog, addFigure }) {
  const [type, setType] = React.useState('Spine')

  const figureTypes = [
    'Spine', 'SkeletonFigure', 'Scale',
    'GraveCrossSection', 'Arrow', 'Good'
  ]

  return (
    <div className='modal d-block' aria-hidden='false'>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h1 className='modal-title fs-5'>New Figure</h1>
            <button type='button' onClick={closeDialog} className='btn-close' aria-label='Close' />
          </div>
          <div className='modal-body'>
            <form>
              <div className='input-group mb-3'>
                <select
                  value={type}
                  onChange={(evt) => setType(evt.target.value)}
                  className='form-select'
                >
                  {figureTypes.map((ft) => (
                    <option key={ft} value={ft}>
                      {ft === 'Good' ? 'Artefact' : ft}
                    </option>
                  ))}
                </select>
              </div>
            </form>
          </div>
          <div className='modal-footer'>
            <button type='button' onClick={closeDialog} className='btn btn-secondary'>
              Close
            </button>
            <button
              type='button'
              onClick={() => { addFigure(type); closeDialog() }}
              className='btn btn-primary'
            >
              Create
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
