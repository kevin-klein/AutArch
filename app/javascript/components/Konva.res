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
