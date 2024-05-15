open Webapi.Canvas
open Js.Array
open Konva
open AutArch

let calculateControlPoints = (figure: figure) => {
  let x1Float = (figure.x1 :> float)
  let y1Float = (figure.y1 :> float)

  [
    {x: (x1Float *. 0.95)->Float.toInt, y: (figure.y1 + figure.y2) / 2, id: 1},
    {x: (figure.x1 + figure.x2) / 2, y: (y1Float *. 0.9)->Float.toInt, id: 2},
    {x: ((figure.x2 :> float) *. 1.05)->Float.toInt, y: (figure.y2 + figure.y1) / 2, id: 3},
    {x: (figure.x1 + figure.x2) / 2, y: ((figure.y2 :> float) *. 1.05)->Float.toInt, id: 4},
  ]
}

@react.component
let make = (~active, ~figure: figure, ~onChangeFigure) => {
  let anchors = [
    {x: figure.anchor_point_1_x, y: figure.anchor_point_1_y, id: 1},
    {x: figure.anchor_point_2_x, y: figure.anchor_point_2_y, id: 2},
    {x: figure.anchor_point_3_x, y: figure.anchor_point_3_y, id: 3},
    {x: figure.anchor_point_4_x, y: figure.anchor_point_4_y, id: 4},
  ]
  let anchorElements = anchors->Array.map(point => {
    <AnchorPoint
      key={Belt.Int.toString(point.id)}
      point={point}
      onChangeFigure={onChangeFigure}
      figure={figure}
    />
  })

  let controlPoints = [
    {x: figure.control_point_1_x, y: figure.control_point_1_y, id: 1},
    {x: figure.control_point_2_x, y: figure.control_point_2_y, id: 2},
    {x: figure.control_point_3_x, y: figure.control_point_3_y, id: 3},
    {x: figure.control_point_4_x, y: figure.control_point_4_y, id: 4},
  ]
  let controlPointElements = controlPoints->Array.map(point => {
    <ControlPoint
      key={Belt.Int.toString(point.id)}
      point={point}
      onChangeFigure={onChangeFigure}
      figure={figure}
    />
  })

  <React.Fragment>
    <Shape
      stroke="red"
      strokeWidth={4}
      sceneFunc={(konvaContext, shape) => {
        konvaContext->beginPath
        let start = anchors[0]
        switch start {
        | Some(point) => konvaContext->moveTo(~x=point.x, ~y=point.y)
        | None => Console.log("point is null")
        }
        for index in 1 to 3 {
          anchors[index]->Option.forEach(anchor => {
            controlPoints[index]->Option.forEach(controlPoint => {
              konvaContext->quadraticCurveTo(
                ~px=controlPoint.x,
                ~py=controlPoint.y,
                ~x=anchor.x,
                ~y=anchor.y,
              )
            })
          })
        }

        let firstControlPoint = controlPoints[0]->Option.getUnsafe
        let firstAnchor = anchors[0]->Option.getUnsafe
        konvaContext->quadraticCurveTo(
          ~px=firstControlPoint.x,
          ~py=firstControlPoint.y,
          ~x=firstAnchor.x,
          ~y=firstAnchor.y,
        )

        konvaContext->fillStrokeShape(~shape)
      }}
    />
    {React.array(anchorElements)}
    {React.array(controlPointElements)}
  </React.Fragment>
}
let default = make
