import React from 'react'
import { Group, Stage, Layer, Circle, Image, Rect, Line, Transformer, Arrow, Shape } from 'react-konva'
import useImage from 'use-image'
import useSWR from 'swr'

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

function PagePreview ({ divRef, changePage, image, highlight, selected, setCurrentRelations, relations, activeArtefact, figures }) {
  // return (
  //   <svg preserveAspectRatio='xMidYMid meet' viewBox={`0 0 ${image.width} ${image.height}`} xmlns='http://www.w3.org/2000/svg'>
  //     <image width={`${image.width}`} height={`${image.height}`} href={`${image.href}`} />

  //     <Contour figure={highlight} />

  //     {graveGoods.map(figure => (
  //       <Contour key={figure.id} figure={figure} selected={selected.includes(figure.id)} onClick={() => setRelatedById(relations, setCurrentRelations, activeArtefact, figure.id)} />
  //     ))}

  //     {figures.map(figure => (
  //       <Contour key={figure.id} figure={figure} selected={selected.includes(figure.id)} onClick={() => setRelatedById(relations, setCurrentRelations, activeArtefact, figure.id)} />
  //     ))}
  //   </svg>
  // )

  const [dimensions, setDimensions] = React.useState({
    width: 0,
    height: 0
  })
  const [stageScale, setStageScale] = React.useState(1)
  const [stageX, setStageX] = React.useState(0)
  const [stageY, setStageY] = React.useState(0)
  React.useEffect(() => {
    setDimensions({
      width: divRef.current.offsetWidth,
      height: (divRef.current.offsetWidth / image.width) * image.height
    })
    setStageScale(divRef.current.offsetWidth / image.width)
  }, [])
  const [imageNode] = useImage(image.href)

  function handleWheel (e) {
    e.evt.preventDefault()

    const scaleBy = 1.3
    const stage = e.target.getStage()
    const oldScale = stage.scaleX()
    const mousePointTo = {
      x: stage.getPointerPosition().x / oldScale - stage.x() / oldScale,
      y: stage.getPointerPosition().y / oldScale - stage.y() / oldScale
    }

    const newScale = e.evt.deltaY < 0 ? oldScale * scaleBy : oldScale / scaleBy

    setStageScale(newScale)
    setStageX(-(mousePointTo.x - stage.getPointerPosition().x / newScale) * newScale)
    setStageY(-(mousePointTo.y - stage.getPointerPosition().y / newScale) * newScale)
  }

  return (
    <Stage
      onWheel={handleWheel}
      scaleX={stageScale}
      scaleY={stageScale}
      x={stageX}
      y={stageY}
      width={dimensions.width}
      draggable
      height={dimensions.height}
    >
      <Layer>
        <Image
          width={image.width}
          height={image.height}
          image={imageNode}
          x={0}
          y={0}
        />
        {Object.values(figures).map(figure => {
          let color = '#0000FF'
          if (selected.includes(figure.id)) {
            color = '#F44336'
          }

          return (
            <Rect
              key={figure.id}
              fill={color + '11'}
              stroke={color}
              fillEnabled
              strokeWidth={3}
              x={figure.x1}
              y={figure.y1}
              width={figure.x2 - figure.x1}
              height={figure.y2 - figure.y1}
              onClick={() => setRelatedById(relations, setCurrentRelations, activeArtefact, figure.id)}
              onTap={() => setRelatedById(relations, setCurrentRelations, activeArtefact, figure.id)}
            />
          )
        })}
      </Layer>
    </Stage>
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
          className={`list-group-item ${selected?.includes(figure.id) ? 'active' : ''}`}
        >
          {figure.type} {figure.id}
        </li>
      ))}
    </ul>
  )
}

function setRelatedById (relations, setRelations, selected, id) {
  console.log('setRelatedById')
  if (selected !== null) {
    if (relations[selected]?.includes(id)) {
      setRelations({ ...relations, [selected]: relations[selected].filter(current => current !== id) })
    } else {
      setRelations({ ...relations, [selected]: [id, ...(relations[selected] || [])] })
    }
  }
}

function GraveDetails ({ graveGoods, grave, figures, relations, setRelations, selected, setSelected }) {
  return (
    <div>
      <h4>OBJ. {grave.identifier}</h4>
      <p><em>Please select all items belonging to the indicated grave.</em></p>
      <div className='row'>
        <div className='col-md-6'>
          <GraveGoodList goods={graveGoods} selected={selected} setSelected={setSelected} />
        </div>
        <div className='col-md-6'>
          <RelatedFiguresList figures={figures} selected={relations[selected]} setSelected={(id) => setRelatedById(relations, setRelations, selected, id)} />
        </div>
      </div>
    </div>
  )
}

const fetcher = (...args) => fetch(...args).then(res => res.json())

export default function Relations ({ publicationId, graveGoods, background, pageNumber, image, highlight, saveUrl, relations }) {
  const [currentRelations, setCurrentRelations] = React.useState(relations)
  const [selected, setSelected] = React.useState(null)
  const [page, setPage] = React.useState(pageNumber)
  const divRef = React.useRef()

  const { data, error, isLoading } = useSWR(`/publications/${publicationId}/pages/by_page_number.json?page=${page}`, fetcher)

  if(isLoading) { return (<div>Loading...</div>) }

  console.log(data)

  const figures = data.figures.filter(figure => ['Ceramic', 'StoneTool', 'Artefact', 'ShaftAxe'].includes(figure.type))

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
      <div className='col-md-4'>
        <PagePreview
          relations={currentRelations}
          selected={[selected, ...(currentRelations[selected] || [])]}
          activeArtefact={selected}
          setCurrentRelations={setCurrentRelations}
          image={image}
          highlight={highlight}
          divRef={divRef}
          figures={graveGoods}
        />
      </div>

      <div className='col-md-4' ref={divRef}>
        <nav aria-label='Page navigation example'>
          <ul className='pagination'>
            <li className='page-item'><a className='page-link' href='#' onClick={() => setPage(page - 1)}>Previous</a></li>
            <li className='page-item'><a className='page-link' href='#' onClick={() => setPage(page + 1)}>Next</a></li>
          </ul>
        </nav>
        <PagePreview
          divRef={divRef}
          relations={currentRelations}
          selected={[selected, ...(currentRelations[selected] || [])]}
          activeArtefact={selected}
          setCurrentRelations={setCurrentRelations}
          image={data.image}
          highlight={highlight}
          figures={figures}
          changePage
        />
      </div>

      <div className='col-md-4'>
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
