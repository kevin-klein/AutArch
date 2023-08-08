import React from 'react';
import {Box} from './BoxResizer';

export default function({grave, image}) {
  const figures = grave.figures;
  return (
    <svg
      viewBox={`0 0 ${image.width} ${image.height}`}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
      <image width={image.width} height={image.height} href={image.href} />
      {Object.values(figures).map(figure => <Box key={figure.id} figure={figure} />)}
    </svg>
  );
}
