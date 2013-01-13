knox = require 'knox'
filesize = require 'filesize'
module.exports =
  home: (req, res, next)->
    res.render "home"
  
  bucketList: (req, res, next)->
    id = req.params.id
    key = req.params.key
    bucket = req.params.bucket
    path = req.url.replace "/#{id}/#{key}/#{bucket}/", ""

    client = knox.createClient {
      key: id
      secret: key
      bucket: bucket
    }
    client.list {prefix:path, delimiter:"/"}, (err, data) ->
      parents = []
      
      if path.length>0
        parents.push {
          name: ".."
          path: ".."
          isFolder: true
        }

      prefixes = data.CommonPrefixes
      if prefixes?
        if not ("map" of prefixes)
          prefixes = [prefixes]
      
        dirs = prefixes.map (prefix)->
          {
            name: prefix.Prefix
            path: prefix.Prefix
            isFolder: true
          }
      else
        dirs = []

      contents = data.Contents
      if not ("map" of contents)
        contents = [contents]
      
      files = contents.map (item) ->
        {
          name:item.Key
          path:item.Key
          size:filesize(item.Size)
          modified:item.LastModified
          isFolder: false
        }

      

      result = parents.concat(dirs, files).map (file)->
        file.path = file.path.replace path, ""
        file.name = file.name.replace path, ""

        icon = if not file.isFolder then file.name else "folder"
        file.icon = "http://mimeicon.herokuapp.com/#{icon}?size=16"
        file
      result = result.filter (file) ->
        file.path.length>0
      path_match = path.match(/\/?([^\/]*)\/$/)
      if path_match
        path_last_component = path_match[1]

      console.error result
      res.render "list", {
        files:result
        path:path_last_component
        bucket:bucket
        url:req.url
      }

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
