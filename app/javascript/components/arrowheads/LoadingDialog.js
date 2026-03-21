import React from 'react'

export default function LoadingDialog () {
  return (
    <div className='modal d-block' aria-hidden='false'>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h1 className='modal-title fs-5'>Processing</h1>
          </div>
          <div className='modal-body'>
            <div className='text-center'>
              <p>Please wait while processing...</p>
              <div className='progress' style={{ height: '8px' }}>
                <div
                  className='progress-bar progress-bar-striped progress-bar-animated'
                  role='progressbar'
                  style={{ width: '100%' }}
                  aria-valuenow='100'
                  aria-valuemin='0'
                  aria-valuemax='100'
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
