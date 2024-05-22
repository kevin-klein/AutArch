type geoData = {rsmKey: string}

type geoInputData = {geographies: array<geoData>}

type projection = {center: array<int>, scale: int}

@module external europeMap: geoData = "./europe.json"

module ComposableMap = {
  @react.component @module("react-simple-maps")
  external make: (
    ~projectionConfig: projection=?,
    ~projection: string=?,
    ~height: int=?,
    ~width: int=?,
    ~children: React.element,
  ) => React.element = "ComposableMap"
}

module ZoomableGroup = {
  @react.component @module("react-simple-maps")
  external make: (
    ~children: React.element
  ) => React.element = "ZoomableGroup"
}

module Geographies = {
  @react.component @module("react-simple-maps")
  external make: (
    ~geography: geoData,
    ~children: (~data: geoInputData) => React.element,
  ) => React.element = "Geographies"
}
module Geography = {
  @react.component @module("react-simple-maps")
  external make: (~geography: geoData) => React.element = "Geography"
}

module Marker = {
  @react.component @module("react-simple-maps")
  external make: (~coordinates: array<float>, ~children: React.element) => React.element = "Marker"
}
