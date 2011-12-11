# Ask the robot to leave the room
#
# leave - let the robot leave the room
module.exports = (robot) ->
  robot.respond /leave$/, (msg) ->
    if msg.message.user.room?
      msg.send "Bye~"
      robot.adapter.bot.part(msg.message.user.room)
    else
      msg.send "Are you kidding me?"
