import React from 'react'

function contourPath (figure, contour) {
  return [...contour, contour[0]].map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`).join(' ')
}

export function Contour ({ figure, onClick, selected }) {
  if (['Grave', 'Arrow', 'GraveCrossSection', 'Scale'].includes(figure.type)) {
    return (
      <React.Fragment key={figure.id}>
        <polyline
          points={contourPath(figure, figure.contour)}
          fill='#3F51B5'
          stroke='#3F51B5'
          strokeWidth='5'
          opacity='.5'
        />
        <text
          x={figure.x1}
          y={figure.y1}
          style={{ fontSize: 36 }}
        >
          {figure.type} {figure.id}
        </text>
      </React.Fragment>
    )
  } else {
    return (
      <>
        <rect
          className='btn'
          fill='none'
          stroke={selected ? 'blue' : 'red'}
          strokeWidth='2'
          x={figure.x1}
          y={figure.y1}
          width={figure.x2 - figure.x1}
          height={figure.x2 - figure.x1}
          onClick={onClick}
        />
        <text
          x={figure.x1}
          y={figure.y1}
          style={{ fontSize: 36 }}
        >
          {figure.type} {figure.id}
        </text>
      </>
    )
  }
}

function PagePreview ({ image, highlight, selected, toggleSelected, figures }) {
  return (
    <svg viewBox={`0 0 ${image.width} ${image.height}`}>
      <image width={`${image.width}`} height={`${image.height}`} href={`${image.href}`} />

      <Contour figure={highlight} />

      {figures.map(figure => (
        <Contour key={figure.id} figure={figure} selected={selected.includes(figure.id)} onClick={() => toggleSelected(figure.id)} />
      ))}
    </svg>
  )
}

function GraveDetails ({ grave, figures }) {
  return (
    <div>
      <h4>OBJ. {grave.identifier}</h4>
      <p><em>Please select all items belonging to the indicated grave.</em></p>
      <ul className='list-group'>
        {figures.map(figure => (
          <li key={figure.id} className='list-group-item'>{figure.type} {figure.id}</li>
        ))}
      </ul>
    </div>
  )
}

export default function Relations ({ background, figures, image, highlight, saveUrl }) {
  const [selected, setSelected] = React.useState([])
  const selectedFigures = figures.filter(figure => selected.includes(figure.id))

  async function onSave () {
    const token =
      document.querySelector('[name=csrf-token]').content

    const response = await fetch(saveUrl, {
      method: 'POST',
      body: JSON.stringify({
        grave_id: highlight.id,
        related: selected
      }),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
  }

  function toggleSelected (id) {
    if (selected.includes(id)) {
      setSelected(prev => {
        return prev.filter(x => x !== id)
      })
    } else {
      setSelected(prev => [...prev, id])
    }
  }

  return (
    <div className='row'>
      <div className='col-md-6'>
        <PagePreview image={image} highlight={highlight} selected={selected} toggleSelected={toggleSelected} figures={figures} />
      </div>

      <div className='col-md-6'>
        <GraveDetails grave={highlight} figures={selectedFigures} />
        <button onClick={onSave} type='button' className='btn btn-primary'>Save</button>
      </div>
    </div>
  )
}
