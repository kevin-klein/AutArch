// import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
// import * as mdb from 'mdb-ui-kit';

import React from 'react'
import 'chartkick/chart.js'
import bootstrap from 'bootstrap'

import BoxResizer from '../components/BoxResizer'
import AddFigures from '../components/AddFigures'
import NorthArrow from '../components/NorthArrow'
import EuropeMap from '../components/EuropeMap'
import ImportProgress from '../components/ImportProgress'
import SiteMap from '../components/SiteMap'
import Chart from "react-apexcharts";

function ScatterChart({ data, colors }) {
  console.log(data)
  console.log(colors)

  const series = data.map(item => ({
    ...item,
    name: `${item.name} (N = ${item.data.length})`,
    data: item.data.map(dataItem => [dataItem.x, dataItem.y])
  }))

  return <Chart type="scatter" series={series} options={{
    tooltip: {
      custom: function({series, seriesIndex, dataPointIndex, w}) {
        return '<div class="arrow_box" style="padding: 10;">' +
          '<span>Grave ' + data[seriesIndex].data[dataPointIndex].title + '</span>' +
          '</div>'
      }
    },
    colors: colors,
    legend: {
      fontSize: 16
    },
    chart: {
      animations: {
        enabled: false
      },
      events: {
        markerClick: function(event, chartContext, { seriesIndex, dataPointIndex, config}) {
          const item = data[seriesIndex].data[dataPointIndex]
          const link = `/graves/${item.id}/update_grave/set_grave_data`
          window.location.href = link
        }
      },
    },
    xaxis: {
      type: 'numeric',
      tickAmount: 10,
      labels: {
        formatter: function(val) {
          return parseFloat(val).toFixed(1)
        }
      }
    },
    yaxis: {
      tickAmount: 8,
      labels: {
        formatter: function(val) {
          return parseFloat(val).toFixed(1)
        }
      }
    },
  }} />
}

import ReactOnRails from 'react-on-rails'
import { Filler, LineElement, PointElement, RadialLinearScale, Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

import Rails from '@rails/ujs'

ChartJS.register(Filler, LineElement, PointElement, ArcElement, Tooltip, Legend, RadialLinearScale)
ReactOnRails.register({
  BoxResizer,
  ImportProgress,
  AddFigures,
  ScatterChart,
  NorthArrow,
  SiteMap: function (props, railsContext) {
    return () => <SiteMap {...props} />
  },
  EuropeMap: function (props, railsContext) {
    return () => <EuropeMap {...props} />
  }
})
Rails.start()
