/* eslint-disable react/prop-types */
import React from 'react';
import {useQuery} from 'graphql-hooks';
import {GRAVE_VIEW_QUERY} from './queries';

function Box({figure: {x1, y1, x2, y2, typeName}}) {
  let color = 'black';

  return (<React.Fragment>
    <defs>
      <marker id="arrowhead" markerWidth="10" markerHeight="7"
        refX="0" refY="3.5" orient="auto">
        <polygon points="0 0, 10 3.5, 0 7" />
      </marker>
    </defs>

    {(typeName === 'spine' || typeName === 'cross_section_arrow') &&
      <line
        fill='none'
        stroke={color}
        strokeWidth="2"
        x1={x1}
        y1={y1}
        x2={x2}
        y2={y2}

        markerEnd="url(#arrowhead)" />
    }

    {typeName !== 'spine' && <rect
      fill='none'
      stroke={color}
      strokeWidth="2"
      x={x1}
      y={y1}
      width={x2 - x1}
      height={y2 - y1}
    />}

    <circle
      className="moveable-point"
      r='4'
      cx={x1}
      cy={y1}
      stroke="black"
    />
    <circle
      className="moveable-point"
      r='4'
      cx={x2}
      cy={y2}
      stroke="black"
    />
  </React.Fragment>)
  ;
}


export default function GraveView({id}) {
  const {data, loading, error} = useQuery(GRAVE_VIEW_QUERY, {
    variables: {
      id: parseInt(id)
    }
  });

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Oh no... {error.message}</p>;

  const grave = data.grave;
  console.log(grave.page.image);

  return (
    <div>
      <svg
        viewBox={`0 0 ${grave.page.image.width} ${grave.page.image.height}`}
        preserveAspectRatio="xMidYMid meet"
        xmlns="http://www.w3.org/2000/svg"
      >
        <image width={grave.page.image.width} height={grave.page.image.height} href={grave.page.image.data} />
        {grave.figures.map(figure => <Box key={figure.id} figure={figure} />)}
      </svg>

    </div>
  );
}
