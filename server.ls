require! \cluster
{http-port}:config = require \./config
require! \net
require! \ip
{each} = require \prelude-ls

if cluster.is-master
    workers = []

    # spawn :: Int -> Void
    spawn = (i) !->
        workers[i] = cluster.fork!
            ..on \exit, -> spawn i

    # spawn a worker for each cpu
    cpus = (require \os).cpus!.length
    [0 til cpus] |> each (i) -> spawn i
    
    server = net.create-server {pause-on-connect: true}, (connection) ->
        workers[(ip.to-long connection.remote-address) % config.workers].send \connection, connection
    server.listen http-port
    console.log "port #{http-port} opened by express"

else 
    
    # create a new express app
    require! \body-parser
    require! \express
    app = express!
        ..use (require \cors)!
        ..use body-parser.json!
        ..use body-parser.urlencoded {extended: false}
        ..use (require \cookie-parser)!
        ..use (require \serve-favicon) __dirname + '/public/img/favicon.ico'

    # separation of routes makes them testable
    (require \./routes)
        |> each ([, method]:route) -> app[method].apply app, route.slice 2
    
    server = app.listen 0, \localhost

    # pass the connection from master to the express server instance
    process.on \message, (message, connection) ->
        if message == \connection
            server.emit \connection, connection
            connection.resume!
