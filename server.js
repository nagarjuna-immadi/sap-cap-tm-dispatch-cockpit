import cds from '@sap/cds'

// The UI manifests use relative OData URIs (odata/v4/...) so the apps also run in the
// Work Zone managed approuter. Locally, cds-plugin-ui5 serves each app under
// /tm.dispatch.<app>/, so strip that prefix from OData calls before CAP routes them.
cds.on('bootstrap', app => {
  app.use((req, _res, next) => {
    const match = /^\/tm\.dispatch\.[^/]+(\/odata\/.*)$/.exec(req.url)
    if (match) req.url = match[1]
    next()
  })
})

export default cds.server
