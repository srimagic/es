env = process.env['NODE_ENV']  || 'production'
port = process.env['NODE_PORT'] || 3010
cluster = require 'cluster'
cpus = require('os').cpus().length

fs = require "fs"
http = require "http"
coffee = require "coffee-middle"
exp = require "express"
less = require "less-middleware"
helpers = require "./utils"
cookies = require 'cookies'

envOptions = {}
helpers.utils.updateEnv envOptions

if !envOptions.isDev and cluster.isMaster
  for i in [0...cpus]
    cluster.fork()
  
  cluster.on 'exit', (worker, code, sig)->
    console.log 'Worker Died:', worker.process.pid, ' on :' , new Date()
    console.log 'Worker:', worker.process.pid , 'exited with ', code ' and sig ', sig
  return

AWS = require 'aws-sdk'
AWS.config.loadFromPath './awsconfig.json'
S3 = new AWS.S3({ params: {Bucket: 'com.mh.img'} })
app = exp(cookies.express())
app.envOptions = envOptions
app.s3 = S3
helpers.utils.app = app
console.log 'num cpus = ', cpus
console.log 'env options = ', envOptions

appDirPrefix = '../modhf'
favicon = appDirPrefix + '/public/ico/favicon.ico'
app.use exp.favicon favicon

pg = require 'pg'
redis = require 'redis'
if redis
  if envOptions.isDev
    redisClient = redis.createClient(6379,'localhost')
  else
    redisClient = redis.createClient(6379,'mh-redis.5rn6dt.0001.usw1.cache.amazonaws.com')
  app.redis = redisClient
app.db = helpers.db

if envOptions.isDev
  app.pg = new pg.Client('tcp://localhost:5432/mh')
else
  cxn_pkg = JSON.parse(fs.readFileSync 'cxn.json', 'utf8')
  app.pg = new pg.Client(cxn_pkg.pg)

app.pg.connect (err)->
  if err
    console.log err
  else
    console.log 'pg good'

pkg = JSON.parse(fs.readFileSync 'package.json', 'utf8')

app.configure 'dev', ->
  app.locals.pretty = true
  
  app.use exp.errorHandler()

  if (log = process.env['NODE_LOG'] ? false) and log is "true"
    app.use helpers.logger

app.configure 'production',  ->

app.configure ->
  app.use exp.compress()

  app.use "/css", less
      src     :  appDirPrefix + "/public/less/"
      dest    :  appDirPrefix + "/public/css/"

  app.set "view engine", "jade"
  app.set "views", appDirPrefix + "/views"
  app.set "x-powered-by", false

  app.use exp.cookieParser()
  if redisClient
    app.use(exp.session({
        secret:'5a3-4%$@af-dafo7w$wer23&294!',
        cookie: { maxAge: 2628000000 },
        store: new (require('express-sessions'))({
                storage: 'redis',
                instance: redisClient,
                host: 'localhost',
                port: 6379,
                collection: 'sessions',
                expire: 86400
            })
    }))
  else
    app.use exp.cookieSession( 'key' : 'sid', 'secret' : 'Ta324%$@afsdafo7wrwer234234!' )
  app.use exp.bodyParser()
  app.use exp.methodOverride()
  app.use helpers.auth.checkAuth('expires' : 3600)

  app.use helpers.baseUrl port
  app.use exp.static appDirPrefix + "/public", {maxAge:604800}
  app.use app.router

  routes = require './routes'
  routes.addRoutes app

  #Expires Header for browser Caching
  app.use helpers.expires( 604800 ) #week

  #this is needed for the mh-sites templates
  app.locals.home_preview_link = '/dashboard/dealer/website/preview/home'
  
app.listen port, ()->
  console.log 'Restart:' + new Date()
  console.log "ModularHomes #{pkg.name} up on #{port}, env: #{env}, pid: #{process.pid}"
