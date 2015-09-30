{rextend} = require \prelude-extension

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