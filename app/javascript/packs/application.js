import loadingAttributePolyfill from "loading-attribute-polyfill/dist/loading-attribute-polyfill.module.js";
import * as mdb from 'mdb-ui-kit';

import 'chartkick/chart.js';
import bootstrap from 'bootstrap';

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);
