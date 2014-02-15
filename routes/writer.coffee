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
    return
    crossword = new @db.Crossword req
    crossword.save (err, crossword)->
      if crossword
          # wrote the crossword
          res.redirect('/')
      else
        res.redirect '/writer?failed'