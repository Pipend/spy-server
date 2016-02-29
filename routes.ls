{promises:{to-callback}} = require \async-ls
require! \cli-color
{log-events, projects}:config = require \./config
require! \pipend-spy

# :: a -> [ExpressRoute]
module.exports = do ->

    # die :: Response -> Error -> Void
    die = (res, err) !->
        console.log err.to-string!
        res.status 500 .end err.to-string!

    return

        # for preventing browsers from making an OPTIONS request
        * \json-parse-plain-text, \use, (req, res, next) ->

            if req.headers[\content-type] != \text/plain
                next!

            # JSON parse POST body if the content type is text/plain
            else
                body = ""
                req.set-encoding \utf8
                req.on \data, (chunk)-> body := body + chunk
                req.on \end, ->
                    try
                        req.body = JSON.parse body
                    catch err
                        return die res, err
                    next!

        * \terminate-empty-request, \use, (req, res, next) -> 
            if req.body then next! else die res, "no event-object passed in the POST body"

        * \record-event, \post, "/:project", (req, res) ->
            {project} = req.params

            if !projects?[project]
                die res, "project #{project} not found"

            else
                
                if !!log-events
                    console.log cli-color.green-bright "#{project} : #{new Date!}"
                    console.log JSON.stringify req.body, null, 4
                    console.log ""

                # TODO: update to-callback function to avoid consumption of exceptions
                err, result <- to-callback ((pipend-spy projects[req.params.project]).record-req req, req.body)

                # prevent consumption of exceptions by to-callback
                <- set-immediate

                if !!err
                    die res, err
                else
                    res.set \Content-Type, \application/javascript
                    res.end JSON.stringify result, null, 4
        ...    