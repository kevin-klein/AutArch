import { MapContainer, TileLayer, Marker, Popup, SVGOverlay } from 'react-leaflet'
import React from 'react'
// import { Radar } from 'react-chartjs-2'
import LeafletMarker from './LeafletMarker'

function Radar ({ angles }) {
  console.log(angles)
  const max = Math.max.apply(Math, Object.values(angles))

  return (
    <svg
      viewBox='0 0 100 100'
      xmlns='<http://www.w3.org/2000/svg>'
    >
      <path strokeWidth='1' stroke='black' d='M50,0,50,100' />
      <path strokeWidth='1' stroke='black' d='M0,50,100,50' />

      {Object.keys(angles).map(angle => {
        const count = angles[angle]
        const intensity = (count / max)
        const fill = `rgb(${intensity * 255} 0  ${(1 - intensity) * 255})`

        return (
          <rect style={{ mixBlendMode: 'plus-darker' }} fill={fill} x='30' y='60' width='18' rx={5} height='30' key={angle} transform={`rotate(${angle} 50 50)`} />
        )
      })}

      <circle cx='50' cy='50' r='40' stroke='#FFFFFFDD' stroke-width='7' fill='none' />
    </svg>
  )
}

export default function EuropeMap ({ orientations }) {
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
      >
        <div>

          <Radar
            angles={orientation.angles}
          />
        </div>

      </LeafletMarker>
    )
  })

  return (
    <div style={{ height: 800 }}>
      <MapContainer scrollWheelZoom style={{ height: '100%' }} center={[48.505, 16]} zoom={7}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
        />
        {markers}
      </MapContainer>
    </div>
  )
}
