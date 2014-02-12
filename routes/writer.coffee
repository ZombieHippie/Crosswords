m = require 'methodder'

module.exports = class Writer
  constructor: (@app, @db)->
    @app.get '/writer', m @get, @
    @app.post '/writer', m @post, @
  get: (req,res) =>
    res.render 'writer.jade', {
        title: 'Write a crossword'
        user: req.session.user}
  post: (req,res) =>
    @writer req.body.username, req.body.password, (err, crossword)->
      console.log {err} if err
      if crossword
          # wrote the crossword
          res.redirect('/')
      else
        res.redirect '/writer?failed'
  writer: (user, crossword, fn) =>
    return fn null, null
    # do something with crossword
    @db.CrossWord