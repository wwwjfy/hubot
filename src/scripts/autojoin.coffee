# Ask the robot to auto join a room when booting
#
# autojoin #<room> - auto join #<room> when booting
# show autojoin - show the rooms the robot will auto join when booting
# remove autojoin #<room> - no longer auto join #<room>
module.exports = (robot) ->
  robot.adapter.bot.addListener 'motd', (motd) ->
    robot.brain.data.autojoin ?= []
    for room in robot.brain.data.autojoin
      robot.adapter.join room

  robot.respond /autojoin (#\S*)$/i, (msg) ->
    room = msg.match[1]
    if !(room in robot.brain.data.autojoin)
      robot.brain.data.autojoin.push room
      msg.send "Fine, I'll add " + room + " next time when I come to this world"
    else
      msg.send "I know, I know, stop being annoying"

  robot.respond /show autojoin$/i, (msg) ->
    if robot.brain.data.autojoin.length > 0
      msg.send "I'll automatically join " + robot.brain.data.autojoin.join(", ")
    else
      msg.send "No, I won't auto join any"

  robot.respond /remove autojoin (#\S*)$/i, (msg) ->
    room = msg.match[1]
    autojoin = robot.brain.data.autojoin
    if room in autojoin
      autojoin.splice(autojoin.indexOf(room), 1)
      msg.send "Got it!"
    else
      msg.send "I don't know anything about " + room
