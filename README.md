Super Ranklist
===============

UP Programming Guild's internal ranklist.

# Usage

In one terminal

```
  % vagrant up
  % vagrant ssh
  % nohup rethinkdb &
  % cd ranklis/build/backend
  % supervisor -w . server.js
```

In another

```
  % bundle exec guard -i
```

Then visit `http://localhost:3000`.
