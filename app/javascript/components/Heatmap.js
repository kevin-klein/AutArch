import React from 'react'
import simpleheat from './simpleheat'

import ImageOne from '../images/orientation2.svg'

export default function Heatmap ({ data, graves, orientation }) {
  const width = 500
  const height = 700

  const [uuid, _] = React.useState(crypto.randomUUID())

  React.useLayoutEffect(() => {
    const newData = data
      .map((point) => [point[0] * width, point[1] * height, 1])

    simpleheat(uuid)
      .data(newData)
      .overlays(graves)
      .radius(15, 20)
      .draw()

    const imgElement = document.getElementById(uuid)
    const img = new Image()
    img.height = 200
    img.width = 200

    if (orientation === 'left') {
      img.src = ImageOne
    } else if (orientation === 'right') {
      img.src = ImageOne
    }

    img.onload = function () {
      const ctx = imgElement.getContext('2d')
      const canvasAspect = imgElement.width / imgElement.height
      const imgAspect = img.width / img.height

      let drawWidth, drawHeight, offsetX, offsetY

      if (imgAspect > canvasAspect) {
        drawWidth = imgElement.width
        drawHeight = imgElement.width / imgAspect
        offsetX = 0
        offsetY = (imgElement.height - drawHeight) / 2
      } else {
        drawHeight = imgElement.height
        drawWidth = imgElement.height * imgAspect
        offsetX = (imgElement.width - drawWidth) / 2
        offsetY = 0
      }

      ctx.save()

      if (orientation === 'left') {
        ctx.drawImage(img, offsetX, offsetY, drawWidth, drawHeight)
      } else {
        ctx.translate(offsetX * 2 + drawWidth, 0)

        ctx.scale(-1, 1)

        ctx.drawImage(img, offsetX, offsetY, drawWidth, drawHeight)
      }

      ctx.restore()
    }
  }, [uuid, orientation])

  return (
    <div style={{ position: 'relative', width, height }}>
      <canvas id={uuid} width={width} height={height} />
    </div>
  )
}
