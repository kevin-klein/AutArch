// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as ReactKonva from "react-konva";
import * as JsxRuntime from "react/jsx-runtime";

function ControlPoint(props) {
  var figure = props.figure;
  var onChangeFigure = props.onChangeFigure;
  var point = props.point;
  return JsxRuntime.jsx(ReactKonva.Circle, {
              draggable: true,
              x: point.x,
              y: point.y,
              radius: 25,
              stroke: "#666",
              fill: "#ddd",
              onDragMove: (function (konvaEvent) {
                  if (point.id === 1) {
                    var newrecord = Caml_obj.obj_dup(figure);
                    return onChangeFigure(figure.id, (newrecord.control_point_1_y = konvaEvent.target.y(), newrecord.control_point_1_x = konvaEvent.target.x(), newrecord));
                  }
                  if (point.id === 2) {
                    var newrecord$1 = Caml_obj.obj_dup(figure);
                    return onChangeFigure(figure.id, (newrecord$1.control_point_2_y = konvaEvent.target.y(), newrecord$1.control_point_2_x = konvaEvent.target.x(), newrecord$1));
                  }
                  if (point.id === 3) {
                    var newrecord$2 = Caml_obj.obj_dup(figure);
                    return onChangeFigure(figure.id, (newrecord$2.control_point_3_y = konvaEvent.target.y(), newrecord$2.control_point_3_x = konvaEvent.target.x(), newrecord$2));
                  }
                  if (point.id !== 4) {
                    return ;
                  }
                  var newrecord$3 = Caml_obj.obj_dup(figure);
                  onChangeFigure(figure.id, (newrecord$3.control_point_4_y = konvaEvent.target.y(), newrecord$3.control_point_4_x = konvaEvent.target.x(), newrecord$3));
                })
            });
}

var make = ControlPoint;

export {
  make ,
}
/* react-konva Not a pure module */
