import React, { useState } from 'react'
import { Marker } from 'react-leaflet'
import ReactDOM from 'react-dom/client'
import L from 'leaflet'

const LeafletMarker = React.forwardRef(
  ({ children, iconOptions, ...rest }, refInParent) => {
    const [ref, setRef] = useState()

    const node = React.useMemo(
      () => (ref ? ReactDOM.createRoot(ref.getElement()) : null),
      [ref]
    )

    return (
      <>
        {React.useMemo(
          () => (
            <Marker
              {...rest}
              ref={r => {
                setRef(r)
                if (refInParent) {
                  // @ts-expect-error fowardref ts defs are tricky
                  refInParent.current = r
                }
              }}
              icon={L.divIcon(iconOptions)}
            />
          ),
          []
        )}
        {ref && node.render(children)}
      </>
    )
  }
)

export default LeafletMarker
