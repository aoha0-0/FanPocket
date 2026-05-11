// app/javascript/controllers/index.js

import { application } from "controllers/application" 

import FlatpickrController from "controllers/flatpickr_controller" 
application.register("flatpickr", FlatpickrController)

import HelloController from "controllers/hello_controller" 
application.register("hello", HelloController)