module.exports = class Index
	constructor:(@app, @db)->
		# navigation bar
		@app.locals nav:{Home:"/"}
		@app.locals rnav:{"Write Crossword":"/writer"}
		@app.get '/', @get
		@app.post '/', @post
		@login = new (require('./login'))(@app, @db)
		@register = new (require('./register'))(@app, @db)
		@verify = new (require('./verify'))(@app, @db)
		@writer = new (require('./writer'))(@app, @db)
	get: (req, res) =>
		res.render('index', {
			title: 'Inkblur'
			user: req.session.user
		})
	post: (req, res) =>
		console.log req.body