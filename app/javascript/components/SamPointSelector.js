import React from 'react'

function LoadingDialog () {
  return (
    <div className='modal d-block' aria-hidden='false'>
      <div className='modal-dialog'>
        <div className='modal-content'>
          <div className='modal-header'>
            <h1 className='modal-title fs-5'>Updating Contours</h1>
          </div>
          <div className='modal-body'>
            <div className='text-center'>
              <p>Please wait while the contours are being processed...</p>

              {/* Bootstrap progress bar */}
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

export default function SamPointSelector ({ figure, image, url }) {
  const [stateFigure, setStateFigure] = React.useState(figure)
  const [samPoints, setSamPoints] = React.useState([])
  const [loading, setLoading] = React.useState(false)

  const svgRef = React.useRef(null)
  let polylines = []

  if (stateFigure.contour.length > 0 && stateFigure.contour[0][0].constructor === Array) {
    console.log('array constructor')
    polylines = stateFigure.contour.map((contour, index) => {
      const points = ([...contour, contour[0]]
        .map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`)
        .join(' '))

      return (
        <polyline
          key={index}
          points={points}
          fill='purple'
          stroke='#3F51B5'
          strokeWidth='5'
          opacity='.9'
        />
      )
    })
  } else if (stateFigure.contour.length > 0) {
    const points = [...stateFigure.contour, stateFigure.contour[0]]
      .map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`)
      .join(' ')

    polylines = (
      <polyline
        points={points}
        fill='purple'
        stroke='#3F51B5'
        strokeWidth='5'
        opacity='.9'
      />
    )
  }
  function onPointClicked (index) {
    setSamPoints(samPoints.slice(0, index).concat(samPoints.slice(index + 1)))
  }

  function onClick (event) {
    const svg = svgRef.current
    const point = svg.createSVGPoint()
    point.x = event.clientX
    point.y = event.clientY

    const ctm = svg.getScreenCTM().inverse()
    const svgPoint = point.matrixTransform(ctm)

    setSamPoints([...samPoints, [Math.round(svgPoint.x), Math.round(svgPoint.y)]])
  }

  async function updatePoints () {
    try {
      setLoading(true)
      const points = samPoints.map((point) => [point[0] - figure.x1, point[1] - figure.y1])
      const result = await fetch(url + '?' + new URLSearchParams({
        points: JSON.stringify(points)
      }).toString())

      const json = await result.json()

      setStateFigure(
        { ...stateFigure, contour: json.contour }
      )
    } catch (e) {
      console.log(e)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <button style={{ position: 'sticky', top: 0, zIndex: 999 }} onClick={updatePoints} className='btn btn-success mb-2'>Update SAM Contours</button>
      {loading && <LoadingDialog />}

      <svg ref={svgRef} viewBox={`0 0 ${image.width} ${image.height}`}>
        <image width={image.width} height={image.height} href={image.url} />

        {polylines}
        <text
          x={figure.x1}
          y={figure.y1}
          style={{ fontSize: 36 }}
        >
          {`${figure.type} ${figure.id} `}
        </text>

        <rect
          fill='white'
          opacity='.3'
          stroke='red'
          strokeWidth='2'
          x={figure.x1}
          y={figure.y1}
          width={figure.x2 - figure.x1}
          height={figure.y2 - figure.y1}
          onClick={onClick}
        />

        {samPoints.map((point, index) => (
          <circle opacity='.8' r='15' cx={point[0]} cy={point[1]} fill='red' key={index} onClick={() => onPointClicked(index)} />
        ))}
      </svg>
    </div>
  )
}
