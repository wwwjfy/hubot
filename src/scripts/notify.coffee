# Notify anything to people in group
#
# notify <group> bla bla - notify people in group anything
# n <group> bla bla - notify people in group anything
# notifychannel in #<channel> <group> bla bla - notify people in group anything
# nc <group> in #<channel> bla bla - notify people in group anything

module.exports = (robot) ->
  robot.respond /(notify|n) ([\w.\-_]+)\s*(.+)$/i, (msg) ->
    group = msg.match[2]
    notification = msg.match[3]

    matchedUsers = robot.usersForGroup group

    if matchedUsers.length > 0
      msg.send matchedUsers.join(", ") + ": " + notification
    else
      msg.send msg.message.user.name + ": no such group"

  robot.respond /(notifychannel|nc) in (#[\w.\-_]+)\s*([\w.\-_]+)\s*(.+)$/i, (msg) ->
    channel = msg.match[2]
    group = msg.match[3]
    notification = msg.match[4]
    console.info(channel)
    console.info(group)
    console.info(notification)

    matchedUsers = robot.usersForGroup group

    if matchedUsers.length > 0
      msg.sendToRoom channel, matchedUsers.join(", ") + ": " + msg.message.user.name + " asked you to " + notification
    else
      msg.send msg.message.user.name + ": no such group"
