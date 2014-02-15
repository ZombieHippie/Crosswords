hash = require('../pass').hash
m = require 'methodder'
nodemailer = require 'nodemailer'
{email:from} = require '../config.js'

module.exports = class Register
	constructor: (@app, @db)->
		@app.get '/register', m @get, @
		@app.post '/register', m @post, @
	get: (req,res) =>
		res.render 'login.jade', {
				title: 'Register to Inkblur'
				user: req.session.user
				isNew: true}
	post: (req,res) =>
		@register req.body.username, req.body.password, req.body.email, (err, user)->
			console.log {err} if err
			if user
				console.log "User logged in:"+user.name
				# Regenerate session when signing in
				# to prevent fixation 
				req.session.regenerate ->
					console.log "Regenerate"
					# Store the user's primary key 
					# in the session store to be retrieved,
					# or in this case the entire user object
					req.session.user = user
					res.redirect('/')
			else
				res.redirect '/register?failed'	
	register: (name, pass, email, fn) =>
		@db.User.findOne {name}, 'name', (err, user) =>
			return fn(err) if err
			# query the db for the given username
			if user
				return fn(new Error('user already registered'))
			# apply the same algorithm to the POSTed password, applying
			# the hash against the pass / salt, if there is a match we
			# found the user
			hash pass, (err, salt, hash) =>
				if(err)
					return fn(err)
				key = Math.floor Math.random() * 0xFFFFFFFFFFFFF
				console.log "Send a verification email to: #{email} with key: #{key}"
				@mail()

				user = new @db.User {
					name
					hash
					salt
					email
					key
				}
				user.save (err)->
					console.log "SAVE: "+name
					console.log err if err
					return if(err) then fn(err) else fn(null, user)
	mail: (email, subject, html)=>
		# create reusable transport method (opens pool of SMTP connections)
		smtpTransport = nodemailer.createTransport "SMTP", {
			service: "Gmail"
			auth: from
		}

		# setup e-mail data with unicode symbols
		mailOptions = {
			from: "Crosswords", # sender address
			to: email, # list of receivers
			subject, # Subject line
			html # html body
		}
		# send mail with defined transport object
		smtpTransport.sendMail mailOptions, (error, response)->
			if(error)
				console.log(error)
			else
				console.log("Message sent: " + response.message)

			# if you don't want to use this transport object anymore, uncomment following line
			smtpTransport.close() # shut down the connection pool, no more messages
	verified: (email, username, link)=>
		@mail email, "Verify User: #{username}", "<h1>Welcome to Crosswords #{username}!</h1><br><p>Follow this link to verify your acount with Crosswords</p><strong style=\"padding:18px;border-radius:5px;background-color:skyblue\"><a href=\"#{link}\">Verify!</a></strong>"