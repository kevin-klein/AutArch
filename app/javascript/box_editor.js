import React from 'react';
import ReactDOM from 'react-dom';
import { html } from 'htm/react';

function Box({creating, x1, x2, y1, y2}) {
  const color =

  return html`

  `;
}

function BoxEditor(props) {
  const [startPos, setStartPos] = React.useState(null);
  const [isCreatingBox, setIsCreatingBox] = React.useState(false);
  const [boxes, setBoxes] = React.useState(props.boxes);

  function onSvgClick(event) {
    setBoxes([...boxes, { x1: event.x, y1: event.y, creating: true, }])
    setIsCreatingBox(true);
  }

  return html`
    <svg onclick=${onSvgClick}>
      <img src="data:image/jpeg;base64, ${props.image}"/>
    </svg>
  `;
}
