import * as React from 'react';

export default function Collapse({children, open}) {
  if(open) {
    return children;
  }
  else {
    return [];
  }
}
