// import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
// import * as mdb from 'mdb-ui-kit';

import React from 'react'
import 'chartkick/chart.js'
import bootstrap from 'bootstrap'

import BoxResizer from '../components/BoxResizer'
import AddFigures from '../components/AddFigures'
import NorthArrow from '../components/NorthArrow'
import EuropeMap from '../components/EuropeMap'
import ImportProgress from '../components/ImportProgress'

import ReactOnRails from 'react-on-rails'
import { Filler, LineElement, PointElement, RadialLinearScale, Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'

import Rails from '@rails/ujs'

ChartJS.register(Filler, LineElement, PointElement, ArcElement, Tooltip, Legend, RadialLinearScale)
ReactOnRails.register({
  BoxResizer,
  ImportProgress,
  AddFigures,
  NorthArrow,
  EuropeMap: function (props, railsContext) {
    return () => <EuropeMap {...props} />
  }
})
Rails.start()
