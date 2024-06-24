import { ScaleControl, MapContainer, TileLayer, useMapEvents, useMap, useMapEvent, Rectangle } from 'react-leaflet'
import React from 'react'
import { useEventHandlers } from '@react-leaflet/core'

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
  return <path fill={fill} d={path} stroke='white' transform='rotate(-90 50 50)' />
}

function Radar ({ angles }) {
  const max = Math.max.apply(Math, Object.values(angles))

  return (
    <svg
      viewBox='0 0 100 100'
      xmlns='<http://www.w3.org/2000/svg>'
    >
      {/* <path strokeWidth='1' stroke='black' d='M50,0,50,100' />
      <path strokeWidth='1' stroke='black' d='M0,50,100,50' /> */}
      <circle cx='50' cy='50' r='27' stroke='blue' strokeWidth='25' fill='none' />

      {Object.keys(angles).map(angle => {
        const count = angles[angle]
        const intensity = (count / max)
        const fill = `rgb(${intensity * 255} 0  ${(1 - intensity) * 255})`

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

  const sizes = orientations.map(orientation => Object.values(orientation.angles).reduce((a, b) => a + b, 0))
  const maxSize = Math.max(...sizes)

  const markers = orientations.map(orientation => {
    const site = orientation.site

    const currentSize = Object.values(orientation.angles).reduce((a, b) => a + b, 0)

    let size = 65
    if (currentSize / maxSize < 0.3) {
      size = 35
    } else if (currentSize / maxSize < 0.6) {
      size = 47
    }

    return (
      <LeafletMarker
        key={site.id} iconOptions={{
          className: 'jsx-marker',
          iconSize: [size * 2, size],
          iconAnchor: [30, 30]
        }}
        position={[orientation.site.lat, orientation.site.lon]}
        eventHandlers={{
          click: (e) => {
            window.location.href = `/graves?search[site_id]=${site.id}`
          }
        }}
      >
        <div>
          {zoom > 9 && <h4 style={{ fontSize: 10, color: 'black', fontWeight: 600, margin: 0 }}>{site.name}</h4>}
          <div style={{ width: size, height: size }}>
            <Radar
              angles={orientation.angles}
            />
          </div>
        </div>

      </LeafletMarker>
    )
  })

  return (
    <>
      <div class='leaflet-bottom leaflet-right' style={{ bottom: 60, right: 5 }}>
        <div style={{ backgroundColor: 'white', padding: 5, borderRadius: 5 }}>
          <div style={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
            <div style={{ width: 35, height: 35 }}>
              <Radar
                angles={{}}
              />
            </div>

            <span>
              1{'..'}{(maxSize * 0.3).toFixed(0) - 1} Graves
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
            <div style={{ width: 47, height: 47 }}>
              <Radar
                angles={{}}
              />
            </div>

            <span>
              {(maxSize * 0.3).toFixed(0)}{'..'}{(maxSize * 0.6).toFixed(0)} Graves
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
            <div style={{ width: 65, height: 65 }}>
              <Radar
                angles={{}}
              />
            </div>

            <span>
              {'> '}{(maxSize * 0.6).toFixed(0)} Graves
            </span>
          </div>
        </div>
      </div>
      {markers}
    </>
  )
}

const POSITION_CLASSES = {
  bottomleft: 'leaflet-bottom leaflet-left',
  bottomright: 'leaflet-bottom leaflet-right',
  topleft: 'leaflet-top leaflet-left',
  topright: 'leaflet-top leaflet-right'
}

const BOUNDS_STYLE = { weight: 1 }

function MinimapBounds ({ parentMap, zoom }) {
  const minimap = useMap()

  // Clicking a point on the minimap sets the parent's map center
  const onClick = React.useCallback(
    (e) => {
      parentMap.setView(e.latlng, parentMap.getZoom())
    },
    [parentMap]
  )
  useMapEvent('click', onClick)

  // Keep track of bounds in state to trigger renders
  const [bounds, setBounds] = React.useState(parentMap.getBounds())
  const onChange = React.useCallback(() => {
    setBounds(parentMap.getBounds())
    // Update the minimap's view to match the parent map's center and zoom
    minimap.setView(parentMap.getCenter(), zoom)
  }, [minimap, parentMap, zoom])

  // Listen to events on the parent map
  const handlers = React.useMemo(() => ({ move: onChange, zoom: onChange }), [])
  useEventHandlers({ instance: parentMap }, handlers)

  return <Rectangle bounds={bounds} pathOptions={BOUNDS_STYLE} />
}

function MinimapControl ({ position, zoom }) {
  const parentMap = useMap()
  const mapZoom = zoom || 2

  // Memoize the minimap so it's not affected by position changes
  const minimap = React.useMemo(
    () => (
      <MapContainer
        style={{ height: 140, width: 140 }}
        center={parentMap.getCenter()}
        zoom={mapZoom}
        dragging={false}
        doubleClickZoom={false}
        scrollWheelZoom={false}
        attributionControl={false}
        zoomControl={false}
      >
        <TileLayer url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png' />
        <MinimapBounds parentMap={parentMap} zoom={mapZoom} />
      </MapContainer>
    ),
    []
  )

  const positionClass =
    (position && POSITION_CLASSES[position]) || POSITION_CLASSES.topright
  return (
    <div className={positionClass}>
      <div className='leaflet-control leaflet-bar'>{minimap}</div>
    </div>
  )
}

function NorthArrowControl ({ position }) {
  const positionClass =
  (position && POSITION_CLASSES[position]) || POSITION_CLASSES.topright
  return (
    <div className={positionClass} style={{ left: 5, bottom: 5 }}>
      <div style={{ backgroundColor: 'white', padding: 5, borderRadius: 5 }}>
        <img src='/arrow.png' style={{ width: 50 }} />
      </div>
    </div>
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
        <MinimapControl position='topright' />
        <ScaleControl position='bottomright' />
        <NorthArrowControl position='bottomleft' />
      </MapContainer>
    </div>
  )
}
