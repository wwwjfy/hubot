Url   = require "url"
Redis = require "redis"

# sets up hooks to persist the brain into redis.
module.exports = (robot) ->
  info   = Url.parse process.env.REDISTOGO_URL || 'redis://localhost:6379'
  client = Redis.createClient(info.port, info.hostname)

  robot.adapter.bot.addListener 'join', (channel, who) ->
    unless robot.userForName who
      client.incr 'hubot:user_id', (err, result) ->
        if !err
          user_id = result
        else
          console.log 'error INCR user_id: ' + err
        robot.userForId user_id, {'name': who}

  client.get 'hubot:user_id', (err, result) ->
    unless err
      unless result
        client.set 'hubot:user_id', 0

  if info.auth
    client.auth info.auth.split(":")[1]

  client.on "error", (err) ->
    console.log "Error #{err}"

  client.on "connect", ->
    console.log "Successfully connected to Redis"

    client.get "hubot:storage", (err, reply) ->
      if err
        throw err
      else if reply
        robot.brain.mergeData JSON.parse(reply.toString())

  robot.brain.on 'save', (data) ->
    client.set 'hubot:storage', JSON.stringify data

  robot.brain.on 'close', ->
    client.quit()
