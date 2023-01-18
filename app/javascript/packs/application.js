// Support component names relative to this directory:
import 'chartkick/chart.js';

var componentRequireContext = require.context('components', true);
var ReactRailsUJS = require('react_ujs');
ReactRailsUJS.useContext(componentRequireContext);
