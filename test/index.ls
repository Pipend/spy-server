require! \assert
{promises:{bindP, from-error-value-callback, new-promise, sequenceP, to-callback}} = require \async-ls
{projects} = require \../config
{MongoClient} = require \mongodb
{each, find, keys, map} = require \prelude-ls
require! \../routes 

describe "routes", ->

    specify "must be able to parse valid JSON POSTed with content-type text/plain", (done) ->

        # get the route handler function (app.use ...)
        [,,handler] = find (.0 == \json-parse-plain-text), routes

        # req mockup
        req =
            headers:
                \content-type : \text/plain
            on: (event-type, listener) ->
                match event-type
                | \data => listener (JSON.stringify {event-type: \test}, null, 4)
                | \end => set-timeout listener, 50
            set-encoding: -> @

        response-status = 200

        handler req, {}, ->
            assert !!req.body, "req.body must be defined and a JSON object"
            assert req.body.event-type == \test, "req.body.event-type must be test instead of #{req?.body?.event-type}"
            done!

    specify "must throw an error if project is not configured", (done) ->
        [,,,handler] = find (.0 == \record-event), routes

        # req mockup
        req =
            body: event-type: \test
            get: -> \localhost
            headers:
                user-argent: \test
            original-url: '/?foo=bar'
            params: 
                project: \undefined
            protocol: \http
            socket:
                remote-address: \127.0.0.1

        # res mockup
        res = 
            status: (code) -> 
                assert.equal code, 500
                @
            end: -> done!

        handler req, res


    specify "POSTing event object to /:project must insert it into configured database", (done) ->
        assert !!projects.test, "please specify storage details for 'test' project in config.ls"
        [,,,handler] = find (.0 == \record-event), routes

        # req mockup
        req =
            body: event-type: \test
            get: -> \localhost
            headers:
                user-argent: \test
            original-url: '/?foo=bar'
            params: 
                project: \test
            protocol: \http
            socket:
                remote-address: \127.0.0.1

        response-status = 200

        # res mockup
        res = 
            status: (code) -> 
                response-status := code
                @
            set: -> @
            end: (json-string) ->
                
                # the response status must be 200                
                assert response-status == 200, "response-status = #{response-status} instead of 200, #{json-string}"

                # the response must be a valid json 
                inserted-events = JSON.parse json-string
                
                assert inserted-events.length == projects.test.length, "inserted-events.length must be #{projects.test.length} instead of #{inserted-events?.length}"
                
                # make sure the events were inserted into the database
                err <- to-callback do ->
                    [0 til projects.test.length] 
                        |> map (index) ->
                            inserted-event = inserted-events?[index]
                            return (new-promise (, rej) -> rej "inserted-event.#{index} must be defined") if !inserted-event
                            return (new-promise (, rej) -> rej "inserted-event.creation-time must be defined") if !inserted-event?.creation-time
                            return (new-promise (, rej) -> rej "inserted-event.event-type must be test instead of #{inserted-event?.event-type}") if inserted-event?.event-type != \test
                            return (new-promise (, rej) -> rej "inserted-event.ip must be 127.0.0.1 instead of #{inserted-event?.ip}") if inserted-event?.ip != req.socket.remote-address
                            return (new-promise (, rej) -> rej "inserted-event.query-tokens.foo must be bar instead of #{inserted-event?.query-tokens?.foo}") if inserted-event?.query-tokens?.foo != \bar
                            {name, connection-string, connection-options, insert-into} = projects.test[index]
                            match name
                                | \mongo =>
                                    db <- bindP (MongoClient.connect connection-string, connection-options)
                                    result <- bindP (db.collection insert-into.collection .find-one {creation-time: inserted-event.creation-time})
                                    if !!result 
                                        db.collection insert-into.collection .remove {creation-time: inserted-event.creation-time}
                                    else
                                        new-promise (, rej) -> rej "did not find any record with creation-time = #{inserted-event.creation-time}"
                                | _ => new-promise (, rej) -> rej "unknown store: #{name}"
                        |> sequenceP
                <- set-immediate
                assert !err, err
                done!
        
        handler req, res
