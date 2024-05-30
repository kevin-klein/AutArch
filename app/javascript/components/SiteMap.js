import React from 'react'
import { MapContainer, ScaleControl, TileLayer, useMap, Marker, Popup } from 'react-leaflet'

// <% @site.graves.each do |grave| %>
// <tr>
//   <td><a href="<%= grave_path(grave) %>"><%= grave.id %></a></td>
// </tr>
// <% end %>

function SiteDetail ({ site }) {
  return (
    <div className='card map-overlay' style={{ width: '18rem' }}>
      <div className='card-body'>
        <h5 className='card-title'>{site.name}</h5>
        <h6 className='card-subtitle mb-2 text-muted'>({site.lat}, {site.lon})</h6>
        <div className='card-text'>
          <table className='table'>
            <thead>
              <tr>
                <th>ID</th>
              </tr>
            </thead>

            <tbody>
              {site.graves.map(grave => (<tr key={grave.id}><td>{grave.id}</td></tr>))}
            </tbody>
          </table>

        </div>
        <a href={`/sites/${site.id}/edit`} className='card-link'>Edit</a>
      </div>
    </div>
  )
}

export default function ({ sites }) {
  const [selectedSite, setSelectedSite] = React.useState(null)

  const markers = sites.map(site => (
    <Marker
      key={site.id} position={[site.lat, site.lon]} eventHandlers={{
        click: () => {
          setSelectedSite(site)
        }
      }}
    />
  ))

  return (
    <div style={{ height: 800 }}>

      <MapContainer center={[50.08804, 14.42076]} zoom={4}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
        />
        <ScaleControl />
        {markers}
        {selectedSite !== null && <SiteDetail site={selectedSite} />}
      </MapContainer>
    </div>
  )
}
