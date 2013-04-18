# This is really just hacked together. This should be rewritten. Haha.

express = require 'express'
app = express()
fs = require 'fs'
r = require 'rethinkdb'
Q = require 'q'
winston = require 'winston'
bcrypt = require 'bcrypt'
passport = require 'passport'
_ = require 'underscore'
LocalStrategy = require('passport-local').Strategy

config = JSON.parse fs.readFileSync 'config.json'

app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.session {secret: '12u 4hdfmcnv u 0wr23'})
app.use(passport.initialize())
app.use(passport.session())

winston.info 'Connecting to database...'

dbDeferred = Q.defer()
r.connect(
  host: '127.0.0.1'
  port: 28015
, (err, conn) ->
  if err
    winston.error err
    dbDeferred.reject(err)
  def = Q.defer()
  r.dbCreate('ranklist').run(conn, (err, res)->
    if err
      winston.debug 'Existing ranklist database used.'
      def.resolve()
    winston.debug 'Ranklist database created.'
    def.resolve()
  )

  def.promise.then( ->
    conn.use 'ranklist'
    tables = ['users', 'groups', 'profiles']
    promises = []
    for table in tables
      do (table=table) ->
        deff = Q.defer()
        promises.push deff.promise
        r.db('ranklist').tableCreate(table).run(conn, (err, res) ->
          if err
            winston.debug "Existing #{table} table used."

          winston.debug "#{table} table created."
          deff.resolve()
        )
    Q.all(promises).then ->
      winston.info 'Seeding db...'
      
      r.db('ranklist').table('users').insert(
        last_name: 'UPPG'
        first_name: 'Admin'
        email: 'admin@upprogrammingguild.org'
        password_hashed: bcrypt.hashSync config.adminPassword, bcrypt.genSaltSync()
        role: 'admin'
      ).run(conn, (err, res) ->
        winston.debug JSON.stringify(res)
        dbDeferred.resolve(conn)
      )
  )
)

serializeUser = (user) ->
  last_name: user.last_name
  first_name: user.first_name
  email: user.email
  role: user.email

dbDeferred.promise.then((conn) ->
  passport.use(new LocalStrategy({
    usernameField: 'email'
    passwordField: 'password'
  }, (email, password, done) ->
    winston.debug 'logging in...'
    r.table('users').filter(email: email).run(conn, (err, cur) ->
      if not cur.hasNext()
        done(null, false, {message: 'Incorrect email.'})
        return
      cur.next((err, user) ->
        if err
          done(err)
          return
        bcrypt.compare(password, user.password_hashed, (err, same) ->
          if same
            done(null, user)
          else
            done(null, false, {message: 'Incorrect password.'})
        )
      )
    )
  ))
  passport.serializeUser (user, done) ->
    done(null, user.id)
  passport.deserializeUser (id, done) ->
    r.table('users').get(id).run(conn, (err, user) ->
      done(err, user)
    )
  # Routes
  app.get '/', (req, res) ->
    res.type 'html'
    fs.readFile "#{__dirname}/../frontend/index.html", {encoding: 'utf8', flag: 'r'}, (err, data) ->
      res.send(200, data)

  app.post '/api/session',
    passport.authenticate('local'),
    (req, res) ->
      res.json serializeUser req.user

  app.get '/api/session', (req, res) ->
    if req.user
      res.json serializeUser req.user
    else
      res.send 403

  app.delete '/api/session', (req, res) ->
    req.logout()
    res.send 200

  app.post '/api/profiles', (req, res) ->
    unless req.user
      res.send 403
      return
    r.table('profiles').insert(req.body.profile).run(conn, (err, status) ->
      if err
        res.send 500
        return
      res.send 200
    )

  app.put '/api/profiles', (req, res) ->
    r.table('profiles').update(req.body.profile).run(conn, (err, status) ->
      if err
        res.send 500
        return
      r.table('profiles').get(req.body.profile.id).run(conn, (err, profile) ->
        if err
          res.send 500
          return
        res.json profile
      )
    )
  
  app.get '/api/profiles', (req, res) ->
    r.table('profiles').run(conn, (err, cur) ->
      if err
        res.send 500
        return
      cur.toArray (err, profiles) ->
        if err
          res.send 500
          return
        res.json profiles
    )

  app.get '/api/profiles/:id', (req, res) ->
    r.table('profiles').get(req.id).run(conn, (err, profile) ->
      if err
        res.send 500
        return
      res.json profile
    )

  app.use '/css', express.static("#{__dirname}/../frontend/css")
  app.use '/js', express.static("#{__dirname}/../frontend/js")
  app.use '/lib', express.static("#{__dirname}/../frontend/lib")
  app.use '/templates', express.static("#{__dirname}/../frontend/templates")

  app.listen 3000
  winston.info 'Listening on port 3000'
, (err) ->
  return
)
