import React from 'react'
import { Circle } from 'react-konva'

export default function ControlPoint ({ figure, onChangeFigure, point }) {
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
            control_point_1_x: konvaEvent.target.x(),
            control_point_1_y: konvaEvent.target.y()
          })
        } else if (point.id === 2) {
          return onChangeFigure(figure.id, {
            ...figure,
            control_point_2_x: konvaEvent.target.x(),
            control_point_2_y: konvaEvent.target.y()
          })
        } else if (point.id === 3) {
          return onChangeFigure(figure.id, {
            ...figure,
            control_point_3_x: konvaEvent.target.x(),
            control_point_3_y: konvaEvent.target.y()
          })
        } else if (point.id === 4) {
          return onChangeFigure(figure.id, {
            ...figure,
            control_point_4_x: konvaEvent.target.x(),
            control_point_4_y: konvaEvent.target.y()
          })
        }
      }}
    />
  )
}
