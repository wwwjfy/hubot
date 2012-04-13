# Assign people to group
#
# <user> is in <group> - add a user to a group
# <user> is not in <group> - remove a user from a group
# who are in <group> - see who are in <group>
# show groups - show all groups

module.exports = (robot) ->
  robot.respond /who are in ([\w.\-_]+)\?*$/i, (msg) ->
    group = msg.match[1]
    group = robot.getFuzzyGroupName group

    matchedUsers = robot.usersForGroup group

    if matchedUsers.length > 1
      msg.send matchedUsers.join(", ") + " are in group " + group
    else if matchedUsers.length == 1
      msg.send matchedUsers[0] + " is in group " + group
    else
      msg.send "no one in group " + group

  robot.respond /([\w.\-_]+) is in (["'\w:\-_]+)[.!]*$/i, (msg) ->
    name = msg.match[1]
    newGroup = msg.match[2].trim()

    unless newGroup.match(/^not\s+/i)
      newGroup = robot.getGroupName newGroup
      if user = robot.userForName name
        user.groups = user.groups or [ ]

        if newGroup in user.groups
          msg.send "I know"
        else
          user.groups.push(newGroup)
          msg.send "Ok, #{name} is in #{newGroup}."
      else
        msg.send "I don't know anything about #{name}."

  robot.respond /([\w.\-_]+) is not in (["'\w:\-_]+)[.!]*$/i, (msg) ->
    name = msg.match[1]
    newGroup = msg.match[2].trim()

    newGroup = robot.getGroupName newGroup
    if user = robot.userForName name
      user.groups = user.groups or [ ]

      if newGroup not in user.groups
        msg.send "I know."
      else
        user.groups = (group for group in user.groups when group isnt newGroup)
        msg.send "Ok, #{name} is no longer #{newGroup}."

    else
      msg.send "I don't know anything about #{name}."

  robot.respond /show groups/i, (msg) ->
    groups = robot.groups()
    msg.send "The groups are: " + groups.join(", ")
