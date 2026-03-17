import React from 'react'
import BoxResizer from './BoxResizer'
import { useFigureStore } from './store'

export default function BoxResizerApiWrapper ({ next_url, grave, sites, image, page }) {
  const token = document.querySelector('[name=csrf-token]').content
  const { figures, setFigures, addFigure, removeFigure } = useFigureStore()

  return (
    <BoxResizer
      next_url={next_url}
      grave={grave}
      sites={sites}
      image={image}
      page={page}
      figures={figures}
      setFigures={setFigures}
      addFigure={addFigure}
      removeFigure={removeFigure}
      token={token}
    />
  )
}
