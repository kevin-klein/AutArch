import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";

import 'chartkick/chart.js';
import bootstrap from 'bootstrap';
import StimulusReflex from 'stimulus_reflex';
import consumer from '../channels/consumer';
import controller from '../controllers';

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);
