# Notify anything to people in group
#
# notify <group> bla bla - notify people in group anything
# n <group> bla bla - notify people in group anything

matchFussyNames = (name, allUsers) ->
  matched = []
  for user in allUsers
    if user.toLowerCase().lastIndexOf(name, 0) == 0
      matched.push user
  # no matching fallback
  if matched.length == 0
    matched.push name
  matched


module.exports = (robot) ->
  robot.respond /(notify|n) ([\w.\-_]+)\s*(.+)$/i, (msg) ->
    group = msg.match[2]
    notification = msg.match[3]

    group = robot.getFuzzyGroupName group
    console.info group

    groupUsers = robot.usersForGroup group
    if groupUsers.length == 0
      msg.send msg.message.user.name + ": no such group"
      return

    activeUsers = robot.adapter.nicklist msg.message.user.room
    matchedUsers = []
    for name in groupUsers
      for matchedName in matchFussyNames name, activeUsers
        matchedUsers.push matchedName

    msg.send matchedUsers.join(", ") + ": " + notification