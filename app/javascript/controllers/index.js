// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from 'controllers/app';

import ApplicationController from './application_controller';
application.register('application', ApplicationController);

import ExampleController from './example_controller';
application.register('example', ExampleController);

import StimulusReflex from 'stimulus_reflex';
import consumer from 'channels/consumer';
import controller from './application_controller';

application.consumer = consumer;
StimulusReflex.initialize(application, { debug: true });
