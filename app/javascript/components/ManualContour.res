open Webapi.Canvas

type figure = {
  page_id: int,
  y1: int,
  y2: int,
  x1: int,
  x2: int,
  id: int
}

type konvaShape

type konvaContext
type konvaTarget
type konvaEvent = {
  target: konvaTarget
}

module KonvaTarget = {
  @send external x: (konvaTarget) => int = "x"
  @send external y: (konvaTarget) => int = "y"
}

@send external beginPath: konvaContext => unit = "beginPath"
@send external moveTo: (konvaContext, ~x: int, ~y: int) => unit = "moveTo"
@send external quadraticCurveTo: (konvaContext, ~px: int, ~py: int, ~x: int, ~y: int) => unit = "quadraticCurveTo"
@send external fillStrokeShape: (konvaContext, ~shape: konvaShape) => unit = "fillStrokeShape"

type sceneFunc = (konvaContext, konvaShape) => unit
type dragCallback = konvaEvent => unit

module Circle = {
  @react.component @module("react-konva")
  external make: (~draggable: bool = ?, ~x: int, ~y: int, ~radius: int, ~stroke: string, ~fill: string, ~onDragMove: dragCallback = ?) => React.element = "Circle"
}

module Shape = {
  @react.component @module("react-konva")
  external make: (~sceneFunc: sceneFunc = ?, ~strokeWidth: int, ~stroke: string) => React.element = "Shape"
}

type point = {
  x: int,
  y: int,
  id: int
}

let calculateControlPoints = (figure: figure) => {
  let x1Float = figure.x1 :> float
  let y1Float = figure.y1 :> float

  [
    { x: (x1Float *. 0.95)->Float.toInt, y: (figure.y1 + figure.y2) / 2, id: 1 },
    { x: (figure.x1 + figure.x2) / 2, y: (y1Float *. 0.9)->Float.toInt, id: 2 },
    { x: ((figure.x2 :> float) *. 1.05)->Float.toInt, y: (figure.y2 + figure.y1) / 2, id: 3 },
    { x: (figure.x1 + figure.x2) / 2 , y: ((figure.y2 :> float) *. 1.05)->Float.toInt, id: 4 }
  ]
}

@react.component
let make = (~active, ~figure: figure) => {
  let shapeRef = React.useRef();
  let trRef = React.useRef();
  let isSelected = active == figure.id
  let (anchors, setAnchors) = React.useState(_ => [
    { x: figure.x1, y: figure.y1, id: 1 },
    { x: figure.x2, y: figure.y1, id: 2 },
    { x: figure.x2, y: figure.y2, id: 3 },
    { x: figure.x1, y: figure.y2, id: 4 }
  ]);
  let (controlPoints, setControlPoints) = React.useState(_ => calculateControlPoints(figure));

  let anchorElements = anchors->Array.map(point => {
    <Circle draggable={true} x={point.x} y={point.y} radius={25} fill={"#ddd"} stroke="#666" onDragMove={konvaEvent => {
      setAnchors(points => {
        points->Array.map(currentPoint => {
          if point.id == currentPoint.id {
            {...currentPoint, x: konvaEvent.target->KonvaTarget.x, y: konvaEvent.target->KonvaTarget.y}
          }
          else {
            currentPoint
          }
        })
      })
    }} />
  })
  let controlPointElements = controlPoints->Array.map(point => {
    <Circle draggable={true} x={point.x} y={point.y} radius={25} fill={"#ddd"} stroke="#666" onDragMove={konvaEvent => {
      setControlPoints(points => {
        points->Array.map(currentPoint => {
          if point.id == currentPoint.id {
            {...currentPoint, x: konvaEvent.target->KonvaTarget.x, y: konvaEvent.target->KonvaTarget.y}
          }
          else {
            currentPoint
          }
        })
      })
    }} />
  })

  <React.Fragment>
    <Shape stroke="red" strokeWidth={4} sceneFunc={(konvaContext, shape) => {
      konvaContext->beginPath;
      let start = anchors[0]
      switch start {
        | Some(point) => konvaContext->moveTo(~x=point.x, ~y=point.y);
        | None => Console.log("point is null")
      }
      for index in 1 to 3 {
        anchors[index]->Option.forEach(anchor => {
          controlPoints[index]->Option.forEach(controlPoint => {
            konvaContext->quadraticCurveTo(~px=controlPoint.x, ~py=controlPoint.y, ~x=anchor.x, ~y=anchor.y)
          })
        })
      }

      let firstControlPoint = controlPoints[0]->Option.getUnsafe
      let firstAnchor = anchors[0]->Option.getUnsafe
      konvaContext->quadraticCurveTo(~px=firstControlPoint.x, ~py=firstControlPoint.y, ~x=firstAnchor.x, ~y=firstAnchor.y)

      konvaContext->fillStrokeShape(~shape=shape);
    }} />

    {React.array(anchorElements)}
    {React.array(controlPointElements)}
  </React.Fragment>
}
let default = make

// %%raw(`
// export default function ManualContour({figure, color, active, onDraggingStart, setActive, onChangeFigure}) {
//   const shapeRef = React.useRef();
//   const trRef = React.useRef();
//   const isSelected = active === figure.id;

//   React.useEffect(() => {
//     if (isSelected) {
//       trRef.current.nodes([shapeRef.current]);
//       trRef.current.getLayer().batchDraw();
//     }
//   }, [isSelected]);

//   return (<React.Fragment>
//     <Circle />

//     <Shape
//       fill={null}
//       fillEnabled={false}
//       stroke={color}
//       strokeWidth={3}
//       x={figure.bounding_box_center_x - figure.bounding_box_width / 2}
//       y={figure.bounding_box_center_y - figure.bounding_box_height / 2}
//       ref={shapeRef}
//       isSelected={true}
//       width={figure.bounding_box_width}
//       height={figure.bounding_box_height}
//       onClick={() => setActive(figure.id)}
//       onTap={() => setActive(figure.id)}
//       rotation={figure.bounding_box_angle}
//       sceneFunc={(ctx, shape) => {
//         ctx.beginPath();
//         ctx.moveTo(quad.start.x(), quad.start.y());
//         ctx.quadraticCurveTo(
//           quad.control.x(),
//           quad.control.y(),
//           quad.end.x(),
//           quad.end.y()
//         );
//         ctx.fillStrokeShape(shape);
//       }}
//       onTransformEnd={(e) => {
//         const node = shapeRef.current;
//         const scaleX = node.scaleX();
//         const scaleY = node.scaleY();

//         node.scaleX(1);
//         node.scaleY(1);

//         const width = node.width() * scaleX;
//         const height = node.height() * scaleY;

//         onChangeFigure(figure.id, {
//           ...figure,
//           bounding_box_center_x: node.x() + width / 2,
//           bounding_box_center_y: node.y() + height / 2,
//           bounding_box_width: width,
//           bounding_box_height: height,
//           bounding_box_angle: node.rotation()
//         });
//       }}
//     />
//     {isSelected && (
//       <Transformer
//         ref={trRef}
//         keepRatio={false}
//         boundBoxFunc={(oldBox, newBox) => {
//           // limit resize
//           if (newBox.width < 5 || newBox.height < 5) {
//             return oldBox;
//           }
//           return newBox;
//         }}
//       />
//     )}
//   </React.Fragment>);
// }
// `)
