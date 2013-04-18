Super Ranklist
===============

UP Programming Guild's internal ranklist.

# Usage

First, 

In one terminal

```
  % npm install
  % bundle install
  % bundle exec guard -i
```

Then, create `build/backend/config.json` with contents:

```
  {
    "adminPassword": "<your password here>"
  }
```

In another,

```
  % vagrant up
  % vagrant ssh
  % sudo npm install -g supervisor
  % nohup rethinkdb &
  % cd ranklis/build/backend
  % supervisor -w . server.js
```

Then visit `http://localhost:3000`.
