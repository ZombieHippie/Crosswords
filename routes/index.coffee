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
		@db.Crossword.find {}, "name user date", (err, data)->
			res.render('index', {
				title: 'Inkblur'
				user: req.session.user
				crosswords: data
			})
	post: (req, res) =>
		console.log req.body