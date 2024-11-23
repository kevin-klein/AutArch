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
import Chart from 'react-apexcharts'
import simpleheat from '../components/simpleheat'
// import h337 from 'heatmap.js'

import ReactOnRails from 'react-on-rails'
import { Filler, LineElement, PointElement, RadialLinearScale, Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

import Rails from '@rails/ujs'

function Heatmap ({ data, graves }) {
  const width = 500
  const height = 700

  React.useLayoutEffect(() => {
    const newData = data
      .map((point) => [point[0] * width, point[1] * height, 1])

    simpleheat('heatmap')
      .data(newData)
      .overlays(graves)
      .radius(15, 20)
      .draw()

    function arrow (context, fromx, fromy, tox, toy) {
      const headlen = 20
      const dx = tox - fromx
      const dy = toy - fromy
      const angle = Math.atan2(dy, dx)
      context.moveTo(fromx, fromy)
      context.lineTo(tox, toy)
      context.lineTo(tox - headlen * Math.cos(angle - Math.PI / 6), toy - headlen * Math.sin(angle - Math.PI / 6))
      context.moveTo(tox, toy)
      context.lineTo(tox - headlen * Math.cos(angle + Math.PI / 6), toy - headlen * Math.sin(angle + Math.PI / 6))
    }

    const ctx = document.getElementById('heatmap').getContext('2d')
    ctx.lineWidth = 3
    ctx.beginPath()
    ctx.globalAlpha = 1
    ctx.strokeStyle = 'black'
    ctx.fillStyle = 'black'
    arrow(ctx, 250, 600, 250, 200)
    ctx.stroke()

    ctx.font = '24px Arial'
    ctx.fillText('Orientation', 260, 400)
  })

  return (<canvas id='heatmap' width={width} height={height} />)
}

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
          '<span>Grave ' + data[seriesIndex].data[dataPointIndex].title + '</span>' +
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
              const link = `/graves/${item.id}/update_grave/set_grave_data`
              window.location.href = link
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

ChartJS.register(Filler, LineElement, PointElement, ArcElement, Tooltip, Legend, RadialLinearScale)
ReactOnRails.register({
  BoxResizer,
  ImportProgress,
  AddFigures,
  ScatterChart,
  NorthArrow,
  Heatmap,
  SiteMap: function (props, railsContext) {
    return () => <SiteMap {...props} />
  },
  EuropeMap: function (props, railsContext) {
    return () => <EuropeMap {...props} />
  }
})
Rails.start()
