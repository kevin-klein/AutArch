import React from 'react'

export default function (props) {
  const { image, next_url } = props
  const [arrow, setArrow] = React.useState(props.arrow)
  const token = document.querySelector('[name=csrf-token]').content

  if (arrow === null) {
    return
  }

  function setArrowAngle (angle) {
    setArrow({ ...arrow, angle })
  }

  const arrowCenterX = (arrow.x1 + arrow.x2) / 2
  const arrowCenterY = (arrow.y1 + arrow.y2) / 2

  return (
    <div className='row'>
      <div className='col-md-6'>
        <svg width='512' height='200' viewBox={`${arrow.x1} ${arrow.y1} ${arrow.x2 - arrow.x1} ${arrow.y2 - arrow.y1}`}>
          <image width={image.width} height={image.height} href={image.href} />
          <g
            transform={`rotate(${arrow.angle} ${arrowCenterX} ${arrowCenterY}) translate(${arrowCenterX - 100} ${arrowCenterY - 80})`}
            stroke='#3F51B5'
            shapeRendering='geometricPrecision'
          >
            <line x1='100' y1='20' x2='100' y2='150' />
            <line x1='100' x2='110' y1='20' y2='40' />
            <line x1='100' x2='90' y1='20' y2='40' />
          </g>
        </svg>
      </div>

      <div className='col-md-6'>
        <button className='btn btn-info' onClick={() => setArrowAngle((arrow.angle + 180) % 360)}>Flip Angle</button>
        <label className='form-label ms-2' htmlFor='arrow-range-input'>Arrow Angle: {arrow.angle}°</label>
        <div className='range'>
          <input id='arrow-range-input' type='range' className='form-range' min='0' max='360' onChange={(evt) => setArrowAngle(evt.target.value || 0)} value={arrow.angle} />
        </div>

        <form action={next_url} method='post'>
          <input type='hidden' name='_method' value='patch' />
          <input type='hidden' name='authenticity_token' value={token} />
          <input type='hidden' name={`figures[${arrow.id}][angle]`} value={arrow.angle} />

          <input value='Next' type='submit' className='btn btn-primary card-link' />
        </form>
      </div>
    </div>
  )
}
