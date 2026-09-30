import cds from '@sap/cds'

// The UI manifests use relative data source URIs (odata/v4/..., and a2a/... for TM
// Assistant) so the apps also run in the Work Zone managed approuter. Locally,
// cds-plugin-ui5 serves each app under /tm.dispatch.<app>/, so strip that prefix from
// OData and A2A calls before CAP routes them.
//
// With mocked (basic) auth, the A2A adapter answers 401 as a JSON-RPC error without a
// WWW-Authenticate header. The browser then never resends the login it cached for the
// agent card (…/.well-known/), because the A2A endpoint is its parent path. Add the
// challenge, with CAP's realm, so TM Assistant's POSTs carry the cached credentials.
const basicAuth = ['mocked', 'basic'].includes(cds.env.requires.auth?.kind)

cds.on('bootstrap', app => {
  app.use((req, res, next) => {
    const match = /^\/tm\.dispatch\.[^/]+(\/(?:odata|a2a)\/.*)$/.exec(req.url)
    if (match) req.url = match[1]
    if (basicAuth && req.url.startsWith('/a2a/')) {
      const writeHead = res.writeHead
      res.writeHead = function (status, ...args) {
        if (status === 401 && !res.getHeader('www-authenticate')) res.setHeader('WWW-Authenticate', 'Basic realm="Users"')
        return writeHead.call(this, status, ...args)
      }
    }
    next()
  })
})

export default cds.server
