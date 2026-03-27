import React, { useState } from 'react'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
// import 'leaflet/dist/leaflet.css'
// import 'leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.css'
import 'leaflet-defaulticon-compatibility'

// Custom marker icon
const createCustomIcon = (selected = false) => {
  return L.divIcon({
    className: 'custom-marker',
    html: `<div style="
      background-color: ${selected ? '#38bdf8' : '#2dd4bf'};
      width: 20px;
      height: 20px;
      border-radius: 50%;
      border: 3px solid #1e293b;
      box-shadow: 0 2px 4px rgba(0,0,0,0.5);
      ${selected ? 'animation: pulse 1.5s infinite;' : ''}
    ">
      <style>
        @keyframes pulse {
          0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(56, 189, 248, 0.7); }
          70% { transform: scale(1.2); box-shadow: 0 0 0 10px rgba(56, 189, 248, 0); }
          100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(56, 189, 248, 0); }
        }
      </style>
    </div>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10],
    popupAnchor: [0, -10]
  })
}

// Modal/Dialog component that wraps the map
function LocationMapDialog ({
  locations = [],
  highlightLocation = null,
  height = 600,
  initialZoom = 6,
  showPopup = true,
  isOpen = true,
  onClose = null,
  title = 'Locations',
  showCloseButton = true,
  showLegend = true
}) {
  // Get map center - focus on highlighted location if provided
  const getMapCenter = () => {
    if (highlightLocation) {
      return [highlightLocation.lat, highlightLocation.lon]
    }

    if (locations.length === 0) {
      return [30.0, 15.0] // Default center for Mediterranean/North Africa
    }

    const latSum = locations.reduce((sum, loc) => sum + (loc.lat || 0), 0)
    const lonSum = locations.reduce((sum, loc) => sum + (loc.lon || 0), 0)

    return [
      latSum / locations.length,
      lonSum / locations.length
    ]
  }

  const markers = locations.map((location, index) => {
    const isSelected = highlightLocation &&
                      highlightLocation.id === location.id ||
                      (highlightLocation?.name === location.name &&
                       highlightLocation?.lat === location.lat &&
                       highlightLocation?.lon === location.lon)

    return (
      <Marker
        key={location.id || index}
        position={[location.lat, location.lon]}
        icon={createCustomIcon(isSelected)}
      >
        {showPopup && (
          <Popup>
            <div>
              <strong>{location.name || `Location ${index + 1}`}</strong>
              <br />
              <span className='text-muted'>
                {location.lat?.toFixed(6)}, {location.lon?.toFixed(6)}
              </span>
            </div>
          </Popup>
        )}
      </Marker>
    )
  })

  const handleClose = () => {
    if (onClose) {
      onClose()
    }
  }

  if (!isOpen) {
    return null
  }

  return (
    <div
      className='modal fade show'
      style={{ display: 'block', backgroundColor: 'rgba(0, 0, 0, 0.5)' }}
      tabIndex='-1'
      role='dialog'
    >
      <div className='modal-dialog modal-fullscreen'>
        <div className='modal-content' style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
          {/* Modal Header */}
          {showCloseButton && (
            <div className='modal-header' style={{ borderBottom: '1px solid #4a5568' }}>
              <h5 className='modal-title' style={{ color: '#f1f5f9' }}>{title}</h5>
              <button
                type='button'
                className='btn-close'
                onClick={handleClose}
                aria-label='Close'
              />
            </div>
          )}

          {/* Modal Body - Map Container */}
          <div className='modal-body' style={{ padding: '0', flex: 1, display: 'flex', flexDirection: 'column', backgroundColor: 'transparent' }}>
            <div style={{ flex: 1, position: 'relative', minHeight: '400px' }}>
              <MapContainer
                center={getMapCenter()}
                zoom={initialZoom}
                style={{ height: '100%', width: '100%' }}
                scrollWheelZoom
                doubleClickZoom={false}
              >
                <TileLayer
                  attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                  url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                  maxZoom={19}
                />

                {markers}
              </MapContainer>

              {/* Legend */}
              {showLegend && (
                <div
                  style={{
                    position: 'absolute',
                    bottom: '10px',
                    right: '10px',
                    backgroundColor: '#1e293b',
                    padding: '10px',
                    borderRadius: '8px',
                    boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
                    zIndex: 1000,
                    fontSize: '12px',
                    border: '1px solid #4a5568'
                  }}
                >
                  <div style={{ marginBottom: '5px' }}>
                    <div style={{
                      display: 'inline-block',
                      width: '12px',
                      height: '12px',
                      borderRadius: '50%',
                      backgroundColor: '#2dd4bf',
                      borderColor: '#1e293b',
                      borderWidth: '2px',
                      marginRight: '5px'
                    }}
                    />
                    <span style={{ color: '#f1f5f9' }}>Normal</span>
                  </div>
                  <div>
                    <div style={{
                      display: 'inline-block',
                      width: '12px',
                      height: '12px',
                      borderRadius: '50%',
                      backgroundColor: '#38bdf8',
                      borderColor: '#1e293b',
                      borderWidth: '2px',
                      marginRight: '5px',
                      animation: 'pulse 1.5s infinite'
                    }}
                    />
                    <span style={{ color: '#f1f5f9' }}>Highlighted</span>
                  </div>
                </div>
              )}

            </div>
          </div>

          {/* Modal Footer */}
          {showCloseButton && (
            <div className='modal-footer' style={{ borderTop: '1px solid #4a5568' }}>
              <button
                type='button'
                className='btn btn-secondary'
                onClick={handleClose}
              >
                Close
              </button>
            </div>
          )}

          {/* Highlighted Location Info */}
          {highlightLocation && (
            <div style={{
              position: 'absolute',
              bottom: '10px',
              left: '10px',
              backgroundColor: '#1e293b',
              padding: '15px',
              borderRadius: '8px',
              boxShadow: '0 2px 4px rgba(0,0,0,0.2)',
              zIndex: 1000,
              maxWidth: '300px',
              border: '1px solid #4a5568'
            }}
            >
              <strong style={{ color: '#f1f5f9' }}>{highlightLocation.name}</strong>
              <div className='text-muted' style={{ color: '#94a3b8' }}>
                {highlightLocation.lat?.toFixed(6)}, {highlightLocation.lon?.toFixed(6)}
              </div>
              {highlightLocation.description && (
                <div style={{ marginTop: '5px', color: '#94a3b8' }}>
                  {highlightLocation.description}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Main LocationMap component
export default function LocationMap ({
  locations = [],
  highlightLocation = null,
  height = 600,
  initialZoom = 8,
  showPopup = true,
  className = '',
  isOpen = true,
  showCloseButton = true,
  showLegend = true,
  onClose = null
}) {
  return (
    <div className={`location-map-container ${className}`}>
      <LocationMapDialog
        locations={locations}
        highlightLocation={highlightLocation}
        height={height}
        initialZoom={initialZoom}
        showPopup={showPopup}
        isOpen={isOpen}
        showCloseButton={showCloseButton}
        showLegend={showLegend}
        onClose={onClose}
      />
    </div>
  )
}
