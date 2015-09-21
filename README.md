Quiet
=====

An attempt to reduce the time I spend doing mail each day. Inspired by Google
Inbox.

Currently just a prototype which connects to Exchange and renders your inbox and
is totally useless (though not ugly).

Usage
-----

Requires Ruby >1.9.

```bash
# create a config.yml file with your Exchange config
cp config.yml.example config.yml
vi config.yml # edit edit edit

# get dependencies
make install

# run the server locally
make run
```

Design
------

- Uses [Viewpoint](https://github.com/WinRb/Viewpoint) to pull email from
  Exchange
- Sinatra app exposes data as a simple REST API
- Angular app renders list of emails and detail
