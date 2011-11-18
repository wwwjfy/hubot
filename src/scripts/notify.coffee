# Notify anything people in group
#
# notify <group> bla bla - notify people in group anything

module.exports = (robot) ->
  robot.respond /notify|n ([\w.-_]+)\s*(.+)$/i, (msg) ->
    group = msg.match[1]
    notification = msg.match[2]

    matchedUsers = robot.usersForGroup group

    if matchedUsers
      msg.send matchedUsers.join(", ") + ": " + notification
    else
      msg.send msg.message.user.name + ": no such group"
