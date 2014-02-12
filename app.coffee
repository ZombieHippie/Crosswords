###
	Module dependencies.
###
express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
mongoose = require 'mongoose'
devreload = require 'devreload'

app = express()

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.locals.pretty = true; # Pretty output from jade

app.use(express.favicon())
app.use(express.logger 'dev')
app.use(express.json())
app.use(express.urlencoded())
app.use(express.methodOverride())

app.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
app.use(express.cookieParser('the truth')) #parses session cookies
app.use(express.session())

app.use(app.router)
app.use(express.static(path.join(__dirname, 'static')))


# development only
if app.get('env') is 'development'
	app.use(express.errorHandler())
	# Use devreload for automatic reloading
	devreload.listen app, {
		watch:[__dirname+'/src',__dirname+'/static',__dirname+'/routes'],
		interval:500, port:9999
	}

# Setup MongoDB
#mongoose.connect 'mongodb://localhost/app'
db = {}
db["User"] = null#mongoose.model 'User', require('./models/User'), 'users'

# Routes
routes = require('./routes')
new routes app, db

http.createServer(app).listen app.get('port'), ->
	console.log 'Express server listening on port ' + app.get 'port'