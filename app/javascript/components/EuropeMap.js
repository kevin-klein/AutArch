import { MapContainer, TileLayer, useMapEvents } from 'react-leaflet'
import React from 'react'
// import { Radar } from 'react-chartjs-2'
import LeafletMarker from './LeafletMarker'

function polarToCartesian (x, y, r, degrees) {
  const radians = degrees * Math.PI / 180.0
  return [x + (r * Math.cos(radians)), y + (r * Math.sin(radians))]
}
function segmentPath (x, y, r0, r1, d0, d1) {
  const arc = Math.abs(d0 - d1) > 180 ? 1 : 0
  const point = (radius, degree) =>
    polarToCartesian(x, y, radius, degree)
      .map(n => n.toPrecision(5))
      .join(',')
  return [
    `M${point(r0, d0)}`,
    `A${r0},${r0},0,${arc},1,${point(r0, d1)}`,
    `L${point(r1, d1)}`,
    `A${r1},${r1},0,${arc},0,${point(r1, d0)}`,
    'Z'
  ].join('')
}

function Segment ({ index, degrees, size, radius, width, fill }) {
  const center = 50
  const start = parseInt(degrees) - 15
  const end = parseInt(degrees) + 15
  const path = segmentPath(center, center, radius, radius - width, start, end)
  return <path fill={fill} d={path} transform='rotate(-90 50 50)' />
}

function Radar ({ angles }) {
  const max = Math.max.apply(Math, Object.values(angles))

  return (
    <svg
      viewBox='0 0 100 100'
      xmlns='<http://www.w3.org/2000/svg>'
    >
      <path strokeWidth='1' stroke='black' d='M50,0,50,100' />
      <path strokeWidth='1' stroke='black' d='M0,50,100,50' />
      <circle cx='50' cy='50' r='27' stroke='blue' strokeWidth='25' fill='none' />

      {Object.keys(angles).map(angle => {
        const count = angles[angle]
        const intensity = (count / max)
        const fill = `rgb(${intensity * 255} 0  ${(1 - intensity) * 255})`

        // return (
        //   <rect style={{ mixBlendMode: 'plus-darker' }} fill={fill} x='30' y='60' width='18' rx={5} height='30' key={angle} transform={`rotate(${angle} 50 50)`} />
        // )
        return (
          <Segment
            radius={40}
            width={40}
            key={angle}
            degrees={angle}
            segments={12}
            fill={fill}
          />
        )
      })}
    </svg>
  )
}

function Markers ({ orientations }) {
  const [zoom, setZoom] = React.useState(0)

  useMapEvents({
    zoomend: (e) => {
      setZoom(e.target._zoom)
    }
  })

  const markers = orientations.map(orientation => {
    const site = orientation.site

    return (
      <LeafletMarker
        key={site.id} iconOptions={{
          className: 'jsx-marker',
          iconSize: [50, 50],
          iconAnchor: [50, 50]
        }}
        position={[orientation.site.lat, orientation.site.lon]}
        eventHandlers={{
          click: (e) => {
            window.location.href = `/graves?search[site_id]=${site.id}`
          }
        }}
      >
        <div>
          {zoom > 9 && <h4 style={{ fontSize: 10, color: 'black', fontWeight: 500 }}>{site.name}</h4>}
          <Radar
            angles={orientation.angles}
          />
        </div>

      </LeafletMarker>
    )
  })

  return (
    <>
      {markers}
    </>
  )
}

export default function EuropeMap ({ orientations }) {
  return (
    <div style={{ height: 800 }}>
      <MapContainer scrollWheelZoom style={{ height: '100%' }} center={[48.505, 16]} zoom={7}>
        <TileLayer
          attribution='Tiles &copy; Esri &mdash; Source: Esri'
          url='https://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}'
        />
        <Markers orientations={orientations} />
      </MapContainer>
    </div>
  )
}
