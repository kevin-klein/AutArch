# Pin npm packages by running ./bin/importmap

pin "application", preload: true

pin_all_from "app/javascript/controllers", under: "controllers"
pin "react", to: "https://ga.jspm.io/npm:react@18.2.0/index.js"
pin "react-dom", to: "https://ga.jspm.io/npm:react-dom@18.2.0/index.js"
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.27/nodelibs/browser/process-production.js"
pin "scheduler", to: "https://ga.jspm.io/npm:scheduler@0.23.0/index.js"
pin "htm", to: "https://ga.jspm.io/npm:htm@3.1.1/dist/htm.module.js"
