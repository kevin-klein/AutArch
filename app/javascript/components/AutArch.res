type point = {
  x: int,
  y: int,
  id: int
}

type figure = {
  page_id: int,
  y1: int,
  y2: int,
  x1: int,
  x2: int,
  id: int,
  control_point_1_x: int,
  control_point_1_y: int,
  control_point_2_x: int,
  control_point_2_y: int,
  control_point_3_x: int,
  control_point_3_y: int,
  control_point_4_x: int,
  control_point_4_y: int,
  anchor_point_1_x: int,
  anchor_point_1_y: int,
  anchor_point_2_x: int,
  anchor_point_2_y: int,
  anchor_point_3_x: int,
  anchor_point_3_y: int,
  anchor_point_4_x: int,
  anchor_point_4_y: int,
  typeName: string,
  controlPoints: array<point>,
  anchors: array<point>,
  manual_bounding_box: bool
}
