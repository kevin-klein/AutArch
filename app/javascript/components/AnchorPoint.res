open Konva
open AutArch

@react.component
let make = (~point: point, ~figure: figure,  ~onChangeFigure) => {
  <Circle
      draggable={true}
      x={point.x}
      y={point.y}
      radius={25}
      fill={"#ddd"}
      stroke="#666"
      onDragMove={konvaEvent => {
        if point.id == 1 {
          onChangeFigure(figure.id, {
            ...figure, anchor_point_1_x: konvaEvent.target->KonvaTarget.x, anchor_point_1_y: konvaEvent.target->KonvaTarget.y
          })
        }
        else if point.id == 2 {
          onChangeFigure(figure.id, {
            ...figure, anchor_point_2_x: konvaEvent.target->KonvaTarget.x, anchor_point_2_y: konvaEvent.target->KonvaTarget.y
          })
        }
        else if point.id == 3 {
          onChangeFigure(figure.id, {
            ...figure, anchor_point_3_x: konvaEvent.target->KonvaTarget.x, anchor_point_3_y: konvaEvent.target->KonvaTarget.y
          })
        }
        else if point.id == 4 {
          onChangeFigure(figure.id, {
            ...figure, anchor_point_4_x: konvaEvent.target->KonvaTarget.x, anchor_point_4_y: konvaEvent.target->KonvaTarget.y
          })
        }
    }} />
}
