# Install
`git clone git@github.com:Pipend/spy-server.git`

# Setup

* `npm install`

* copy the following to `config.ls`
```
require! \./rextend

default-mongo-storage-details = 
    name: \mongo    
    connection-options: 
        auto_reconnect: true
        db:
          w:1
        server:
          socket-options:
              keepAlive: 1
    insert-into: 
        collection: \events  

module.exports = 

    http-port: 3010
    log-events: false

    projects:
        test: [{} <<< default-mongo-storage-details <<< {connection-string: \mongodb://localhost:27017/test}]

```

* `lsc server.ls`

# Testing & Coverage

* `gulp build` to transpile livescript files to javascript
* `npm test` & `npm run coverage` for unit tests & coverage

