// import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
// import * as mdb from 'mdb-ui-kit';

import React from 'react'
import 'chartkick/chart.js'
import bootstrap from 'bootstrap'

import SamPointSelector from '../components/SamPointSelector'
import BoxResizer from '../components/BoxResizer'
import AddFigures from '../components/AddFigures'
import NorthArrow from '../components/NorthArrow'
import EuropeMap from '../components/EuropeMap'
import ImportProgress from '../components/ImportProgress'
import SiteMap from '../components/SiteMap'
import Chart from 'react-apexcharts'
import simpleheat from '../components/simpleheat'
import Relations from '../components/Relations'
// import h337 from 'heatmap.js'
import * as OV from 'online-3d-viewer'

import ReactOnRails from 'react-on-rails'
import { Filler, LineElement, PointElement, RadialLinearScale, Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

import Rails from '@rails/ujs'

function Heatmap ({ data, graves, orientation }) {
  const width = 500
  const height = 700

  const [uuid, _] = React.useState(crypto.randomUUID())

  console.log(uuid)

  React.useLayoutEffect(() => {
    const newData = data
      .map((point) => [point[0] * width, point[1] * height, 1])

    simpleheat(uuid)
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

    function drawSkeleton (context) {
      context.beginPath()

      // Draw body
      if (orientation === 'left') {
        context.moveTo(width * 0.5, height * 0.75)
        context.lineTo(width * 0.65, height * 0.65)
        context.lineTo(width * 0.5, height * 0.55)
        context.lineTo(width * 0.5, height * 0.35)
      } else if (orientation === 'right') {
        context.moveTo(width * 0.5, height * 0.75)
        context.lineTo(width * 0.35, height * 0.65)
        context.lineTo(width * 0.5, height * 0.55)
        context.lineTo(width * 0.5, height * 0.35)
      }

      // ctx.fill()
      ctx.stroke()

      // Draw left leg if right-oriented or right leg if left-oriented
      // const footX = orientation === 'left' ? 200 : 300
      // context.moveTo(baseLine, height - 100)
      // context.lineTo(footX, height - 150)

      // Draw head
      // ctx.fill()

      // Draw arms
      // if (orientation === 'left') {
      //   context.moveTo(baseLine + 70, height / 2)
      //   arrow(context, baseLine + 70, height / 2, 300, height / 2 - 50)

      //   context.moveTo(baseLine + 150, height / 2)
      //   arrow(context, baseLine + 150, height / 2, 200, height / 2 - 80)
      // } else {
      //   context.moveTo(250 - 70, height / 2)
      //   arrow(context, 250 - 70, height / 2, 50, height / 2 - 50)

      //   context.moveTo(250 - 150, height / 2)
      //   arrow(context, 250 - 150, height / 2, 100, height / 2 - 80)
      // }

      // Stroke and fill paths
      // context.stroke()
      // context.fill()

      ctx.beginPath()

      context.arc(width / 2, height * 0.35, 35, 0, Math.PI * 2) // Head circle
      ctx.fill()
    }

    const ctx = document.getElementById(uuid).getContext('2d')
    ctx.lineWidth = 3
    // ctx.beginPath()
    // ctx.globalAlpha = 1
    ctx.strokeStyle = 'black'
    ctx.fillStyle = 'black'
    // arrow(ctx, 250, 600, 250, 200)
    drawSkeleton(ctx)
    // ctx.stroke()
  }, [uuid])

  return (<canvas id={uuid} width={width} height={height} />)
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

window.addEventListener('load', () => {
  OV.Init3DViewerElements()
})

ChartJS.register(Filler, LineElement, PointElement, ArcElement, Tooltip, Legend, RadialLinearScale)
ReactOnRails.register({
  BoxResizer,
  ImportProgress,
  AddFigures,
  ScatterChart,
  NorthArrow,
  Heatmap,
  SamPointSelector,
  Relations: function (props, railsContext) {
    return () => <Relations {...props} />
  },
  SiteMap: function (props, railsContext) {
    return () => <SiteMap {...props} />
  },
  EuropeMap: function (props, railsContext) {
    return () => <EuropeMap {...props} />
  }
})
Rails.start()
