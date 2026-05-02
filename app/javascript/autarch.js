// import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
// import * as mdb from 'mdb-ui-kit';

import React from 'react'
import 'chartkick/chart.js'
import * as Popper from '@popperjs/core'
import { createRoot } from 'react-dom/client'

import './autarch.css'

import ArrowHeads from './components/ArrowHeads'
import CeramicWizard from './components/CeramicWizard'
import SamPointSelector from './components/SamPointSelector'
import BoxResizer from './components/BoxResizer'
import AddFigures from './components/AddFigures'
import NorthArrow from './components/NorthArrow'
import EuropeMap from './components/EuropeMap'
import ImportProgress from './components/ImportProgress'
import SiteMap from './components/SiteMap'
import KioskConfig from './components/KioskConfig'
import SelectCeramic from './components/SelectCeramic'
import LocationMap from './components/LocationMap'
import PatternPartSelector from './components/PatternPartSelector'
import Heatmap from './components/Heatmap'
import SummarySourcesModal from './components/SummarySourcesModal'

import Chart from 'react-apexcharts'

import Relations from './components/Relations'
import * as OV from 'online-3d-viewer'
import { Filler, LineElement, PointElement, RadialLinearScale, Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

import Rails from '@rails/ujs'
import { polyfillCountryFlagEmojis } from "country-flag-emoji-polyfill";
polyfillCountryFlagEmojis();

function ScatterChart ({ data, colors }) {
  const series = data.map(item => ({
    ...item,
    name: `${item.name} (N = ${item.data.length})`,
    data: item.data.map(dataItem => [dataItem.x, dataItem.y])
  }))

  return (
    <Chart
      type='scatter' series={series} options={{
        tooltip: {
          custom: function ({ series, seriesIndex, dataPointIndex, w }) {
            return '<div class="arrow_box" style="padding: 10;">' +
          '<span>Object ' + data[seriesIndex].data[dataPointIndex].title + '</span>' +
          '</div>'
          }
        },
        colors,
        legend: {
          fontSize: 16
        },
        chart: {
          animations: {
            enabled: false
          },
          events: {
            markerClick: function (event, chartContext, { seriesIndex, dataPointIndex, config }) {
              const item = data[seriesIndex].data[dataPointIndex]
              if (item.link !== undefined) {
                window.location.href = item.link
              } else {
                const link = `/graves/${item.id}/update_grave/set_grave_data`
                window.location.href = link
              }
            }
          }
        },
        xaxis: {
          type: 'numeric',
          tickAmount: 10,
          labels: {
            formatter: function (val) {
              return parseFloat(val).toFixed(1)
            }
          }
        },
        yaxis: {
          tickAmount: 8,
          labels: {
            formatter: function (val) {
              return parseFloat(val).toFixed(1)
            }
          }
        }
      }}
    />
  )
}

window.addEventListener('load', () => {
  OV.Init3DViewerElements()
})

ChartJS.register(Filler, LineElement, PointElement, ArcElement, Tooltip, Legend, RadialLinearScale)

const COMPONENT_REGISTRY = {
  BoxResizer,
  ImportProgress,
  AddFigures,
  ScatterChart,
  NorthArrow,
  Heatmap,
  SamPointSelector,
  Relations,
  SiteMap,
  EuropeMap,
  ArrowHeads,
  CeramicWizard,
  KioskConfig,
  SelectCeramic,
  LocationMap,
  PatternPartSelector,
  SummarySourcesModal
}

function mountReactComponents () {
  const mountPoints = document.querySelectorAll('[data-react-component]')

  mountPoints.forEach((el) => {
    const name = el.getAttribute('data-react-component')
    const Component = COMPONENT_REGISTRY[name]

    if (Component) {
      const props = JSON.parse(el.getAttribute('data-props') || '{}')
      
      // For SummarySourcesModal, we need to handle it differently
      if (name === 'SummarySourcesModal') {
        // Create a container for the modal
        const container = document.createElement('div');
        container.id = `summarySourcesModalContainer-${props.figureId}`;
        
        // Insert the container after the button
        el.parentNode.insertBefore(container, el.nextSibling);
        
        // Create and render the component
        const root = createRoot(container);
        root.render(<Component {...props} />);
      } else {
        const root = createRoot(el)
        root.render(<Component {...props} />)
      }
    } else {
      console.warn(`React Component "${name}" not found in registry.`)
    }
  })
}

window.addEventListener('load', mountReactComponents)

Rails.start()
