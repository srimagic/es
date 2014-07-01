exp = require 'express'
coffee = require 'coffee-middle'
es = require 'elasticsearch'
appHome = '../hh'

app = exp()

app.es = es.Client()

app.configure ->
  app.set "view engine", "jade"
  app.set "views", appHome + "/views"
  app.set "x-powered-by", false
  app.use (exp.static "./public", {maxAge: 604800})

search = require './search.coffee'
search.addRoutes app

app.listen 4010, () ->
  console.log 'app started'
  console.log 'id: ', process.pid