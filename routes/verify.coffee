hash = require('../pass').hash

module.exports = class Login
  constructor:(@app, @db)->
    @app.get '/verify', @get
  get: (req, res)=>
    @verify req.query.username, parseInt(req.query.key), (err, user)=>
      if (not err) and user
        console.log "User verified and logged in:"+user.name
        # Regenerate session when signing in
        # to prevent fixation
        req.session.regenerate =>
          console.log "Regenerate"
          # Store the user's primary key 
          # in the session store to be retrieved,
          # or in this case the entire user object
          req.session.user = user
          res.redirect('/')
      else
        if err
          err.printStackTrace()
        res.redirect '/login?failed'

  verify: (name, key, fn)=>
    console.log "verify:",{name, key}
    @db.User.findOne {name, key}, '_id name key', (err, user) ->
      return fn(err) if err
      # query the db for the given username
      if (!user)
        return fn(new Error('cannot find user / invalid registration key'))
      # User is registered so set key to null
      user.key = null
      user.save (err)->
        fn(err, user)