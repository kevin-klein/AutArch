import React from 'react'
import { Circle } from 'react-konva'

export default function AnchorPoint ({ onChangeFigure, figure, point }) {
  return (
    <Circle
      draggable
      x={point.x}
      y={point.y}
      radius={25}
      stroke='#666'
      fill='#ddd'
      onDragMove={function (konvaEvent) {
        if (point.id === 1) {
          return onChangeFigure(figure.id, {
            ...figure,
            anchor_point_1_y: konvaEvent.target.y(),
            anchor_point_1_x: konvaEvent.target.x()
          })
        }
        if (point.id === 2) {
          return onChangeFigure(figure.id, {
            ...figure,
            anchor_point_2_y: konvaEvent.target.y(),
            anchor_point_2_x: konvaEvent.target.x()
          })
        }
        if (point.id === 3) {
          return onChangeFigure(figure.id, {
            ...figure,
            anchor_point_3_y: konvaEvent.target.y(),
            anchor_point_3_x: konvaEvent.target.x()
          })
        } else if (point.id === 4) {
          return onChangeFigure(figure.id, {
            ...figure,
            anchor_point_4_y: konvaEvent.target.y(),
            anchor_point_4_x: konvaEvent.target.x()
          })
        }
      }}
    />
  )
}
