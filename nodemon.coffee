# This is for development purposes
ndm = require 'nodemon'
devreload = require 'devreload'
p = require 'path'
# Use devreload for reloading the browser
devreload.listen {watch:null, port:9999}

std = (data)->console.log data.toString()

gen = (type, callback)->
  # Generate client styles/scripts on server reload
  spawn = require('child_process').spawn 'cmd', ["/c", "cake", 'build:'+type]
  console.log "Generating #{type} files"
  spawn.on 'error', std
  spawn.stdout.on 'data', std
  spawn.stderr.on 'data', std
  spawn.on 'exit', callback
checkGenSrc = (callback)->
  if '--gensrc' in process.argv
    gen 'src', callback
  else callback()
checkGenVendors = (callback)->
  if '--genvendors' in process.argv
    gen 'vendors', callback
  else callback()
checkGen = (callback)->
  checkGenSrc ->
    checkGenVendors callback
start = ->
  ext = 'jade coffee'
  watch = ['routes/','app.coffee']
  if '--genvendors' in process.argv
    watch.push 'vendors/'
    ext += ' js css'
  if '--gensrc' in process.argv
    watch.push 'src/'
    ext += ' styl'
  ndm {
    script:'app.coffee'
    watch
    ext
  }
  .on 'restart', (files)->
    checkGen ->
      devreload.reload()
  .on 'log', (log) ->
    console.log log.colour
checkGen ->
  start()