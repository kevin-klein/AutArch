import React from 'react'

function contourPath (figure, contour) {
  return [...contour, contour[0]].map(point => `${point[0] + figure.x1},${point[1] + figure.y1}`).join(' ')
}

export function Contour ({ figure, onClick, selected }) {
  if (['Grave', 'Arrow', 'GraveCrossSection', 'Scale'].includes(figure.type)) {
    if (figure.contour.length > 0) {
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
    }
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
          height={figure.y2 - figure.y1}
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

function PagePreview ({ graveGoods, image, highlight, selected, toggleSelected, figures }) {
  return (
    <svg preserveAspectRatio='xMidYMid meet' viewBox={`0 0 ${image.width} ${image.height}`} xmlns='http://www.w3.org/2000/svg'>
      <image width={`${image.width}`} height={`${image.height}`} href={`${image.href}`} />

      <Contour figure={highlight} />

      {graveGoods.map(figure => (
        <Contour key={figure.id} figure={figure} selected={selected === figure.id} onClick={() => toggleSelected(figure.id)} />
      ))}

      {figures.map(figure => (
        <Contour key={figure.id} figure={figure} selected={selected === figure.id} onClick={() => toggleSelected(figure.id)} />
      ))}
    </svg>
  )
}

function GraveGoodList ({ goods, selected, setSelected }) {
  return (
    <ul className='list-group'>
      {goods.map(figure => (
        <li
          onClick={() => setSelected(figure.id)}
          key={figure.id}
          className={`list-group-item ${selected === figure.id ? 'active' : ''}`}
        >
          {figure.type} {figure.id}
        </li>
      ))}
    </ul>
  )
}

function RelatedFiguresList ({ figures, selected, setSelected }) {
  return (
    <ul className='list-group'>
      {figures.map(figure => (
        <li
          key={figure.id}
          onClick={() => setSelected(figure.id)}
          className={`list-group-item ${selected === figure.id ? 'active' : ''}`}
        >
          {figure.type} {figure.id}
        </li>
      ))}
    </ul>
  )
}

function GraveDetails ({ graveGoods, grave, figures, relations, setRelations, selected, setSelected }) {
  function setRelatedById (id) {
    if (selected !== null) {
      if (relations[selected] === id) {
        setRelations({ ...relations, [selected]: null })
      } else {
        setRelations({ ...relations, [selected]: id })
      }
    }
  }

  return (
    <div>
      <h4>OBJ. {grave.identifier}</h4>
      <p><em>Please select all items belonging to the indicated grave.</em></p>
      <div className='row'>
        <div className='col-md-6'>
          <GraveGoodList goods={graveGoods} selected={selected} setSelected={setSelected} />
        </div>
        <div className='col-md-6'>
          <RelatedFiguresList figures={figures} selected={relations[selected]} setSelected={setRelatedById} />
        </div>
      </div>
    </div>
  )
}

export default function Relations ({ graveGoods, background, figures, image, highlight, saveUrl, relations }) {
  const [currentRelations, setCurrentRelations] = React.useState(relations)
  const [selected, setSelected] = React.useState(null)

  async function onSave () {
    const token =
      document.querySelector('[name=csrf-token]').content

    const response = await fetch(saveUrl, {
      method: 'POST',
      body: JSON.stringify({
        grave_id: highlight.id,
        relations: currentRelations
      }),
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      }
    })
  }

  return (
    <div className='row'>
      <div className='col-md-6'>
        <PagePreview
          selected={currentRelations[selected]}
          setSelected={setSelected}
          graveGoods={graveGoods}
          image={image}
          highlight={highlight}
          figures={figures}
        />
      </div>

      <div className='col-md-6'>
        <GraveDetails
          graveGoods={graveGoods}
          grave={highlight}
          selected={selected}
          setSelected={setSelected}
          figures={figures}
          relations={currentRelations}
          setRelations={setCurrentRelations}
        />
        <button onClick={onSave} type='button' className='btn btn-primary'>Save</button>
      </div>
    </div>
  )
}
