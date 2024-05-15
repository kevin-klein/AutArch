// import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
// import * as mdb from 'mdb-ui-kit';

import 'chartkick/chart.js';
import bootstrap from 'bootstrap';

import BoxResizer from '../components/BoxResizer';
import AddFigures from '../components/AddFigures';
import NorthArrow from '../components/NorthArrow';

import ReactOnRails from 'react-on-rails';
ReactOnRails.register({ BoxResizer, AddFigures, NorthArrow });

import Rails from '@rails/ujs';
Rails.start();
