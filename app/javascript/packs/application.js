// Support component names relative to this directory:
import 'chartkick/chart.js';
import bootstrap from 'bootstrap';

var componentRequireContext = require.context('components', true);
var ReactRailsUJS = require('react_ujs');
ReactRailsUJS.useContext(componentRequireContext);
