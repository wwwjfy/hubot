# Notify anything to people in channel
#
# notifyall bla bla - notify people in channel anything
# nall bla bla - notify people in channel anything

module.exports = (robot) ->
  robot.respond /(notifyall|nall) (.+)$/i, (msg) ->
    notification = msg.match[2]
    users = robot.adapter.nicklist(msg.message.user.room)

    msg.send users.join(", ") + ": " + notification
