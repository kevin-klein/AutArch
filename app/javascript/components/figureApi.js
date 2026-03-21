import { calculateControlPoints } from './ManualContour'

const CSRF_TOKEN = document.querySelector('[name=csrf-token]').content

export async function createFigureApi(type, coords, grave, page) {
  let x1, y1, x2, y2

  if (coords) {
    x1 = coords.x1
    y1 = coords.y1
    x2 = coords.x2
    y2 = coords.y2
  } else if (grave) {
    const { x1: graveX1, x2: graveX2, y1: graveY1, y2: graveY2 } = grave
    const graveWidth = graveX2 - graveX1
    const graveHeight = graveY2 - graveY1

    if (type === 'Spine') {
      x1 = graveX1 + graveWidth * 0.5
      x2 = graveX1 + graveWidth * 0.5
      y1 = graveY1 + graveHeight * 0.6
      y2 = graveY1 + graveHeight * 0.4
    } else {
      x1 = graveX1 + graveWidth * 0.3
      x2 = graveX1 + graveWidth * 0.6
      y1 = graveY1 + graveHeight * 0.4
      y2 = graveY1 + graveHeight * 0.6
    }
  } else {
    x1 = 0; y1 = 0; x2 = 100; y2 = 100
  }

  const response = await fetch('/figures.json', {
    method: 'POST',
    body: JSON.stringify({
      grave_id: grave.id,
      figure: {
        x1, x2, y1, y2,
        page_id: page.id,
        type,
        parent_id: grave.id
      }
    }),
    headers: {
      'X-CSRF-Token': CSRF_TOKEN,
      'Content-Type': 'application/json'
    }
  })

  if (!response.ok) {
    return Promise.reject(response)
  }

  return await response.json()
}

export async function removeFigureApi(id) {
  const response = await fetch(`/figures/${id}.json`, {
    method: 'DELETE',
    headers: {
      'X-CSRF-Token': CSRF_TOKEN,
      'Content-Type': 'application/json'
    }
  })

  if (!response.ok) {
    return Promise.reject(response)
  }

  return response.ok
}

export async function updateFigureApi(id, figureData) {
  const response = await fetch(`/figures/${id}.json`, {
    method: 'PATCH',
    body: JSON.stringify({ figure: figureData }),
    headers: {
      'X-CSRF-Token': CSRF_TOKEN,
      'Content-Type': 'application/json'
    }
  })

  if (!response.ok) {
    return Promise.reject(response)
  }

  return await response.json()
}

export function calculateFigureControlPoints(figure) {
  if (figure.control_point_1_x !== null) {
    return figure
  }

  const controlPoints = calculateControlPoints(figure)
  return {
    typeName: figure.type,
    ...figure,
    control_point_1_x: controlPoints[0].x,
    control_point_1_y: controlPoints[0].y,
    control_point_2_x: controlPoints[1].x,
    control_point_2_y: controlPoints[1].y,
    control_point_3_x: controlPoints[2].x,
    control_point_3_y: controlPoints[2].y,
    control_point_4_x: controlPoints[3].x,
    control_point_4_y: controlPoints[3].y,
    anchor_point_1_x: figure.x1,
    anchor_point_1_y: figure.y1,
    anchor_point_2_x: figure.x2,
    anchor_point_2_y: figure.y1,
    anchor_point_3_x: figure.x2,
    anchor_point_3_y: figure.y2,
    anchor_point_4_x: figure.x1,
    anchor_point_4_y: figure.y2
  }
}
