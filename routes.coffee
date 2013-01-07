knox = require 'knox'
module.exports =
  home: (req, res, next)->
    res.render "home" 
  

  bucketFile: (req, res, next) ->
    id = req.params.id
    key = req.params.key
    bucket = req.params.bucket
    path = req.url.replace "/#{id}/#{key}/#{bucket}/", ""
    if path.length==0
      path = "index.html"

    client = knox.createClient {
      key: id
      secret: key
      bucket: bucket
    }
    s3req = client.getFile path, (err, result) ->
      res.header "Content-Type", result.headers["content-type"]
      result.on 'data', (chunk) ->
        res.write chunk
      result.on 'end', () ->
        res.end()
