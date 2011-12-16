# Hot load scripts
#
# load <script file name> - load script in directory scripts

Path = require 'path'
module.exports = (robot) ->

  pathRegMap = new Object()

  robot.respond /load (.*)$/i, (msg) ->
    scriptsPath = Path.resolve ".", "scripts"
    path = Path.join scriptsPath, msg.match[1]
    Path.exists path, (exists) =>
      if exists
        # unload the old one
        regexArr = pathRegMap[path]
        if regexArr && regexArr.length > 0
          toBeRemoved = []
          for index, listener of robot.listeners
            for regex in regexArr
              if listener.regex.source == regex
                toBeRemoved.push(index)
          if toBeRemoved.length > 0
            for index in toBeRemoved.reverse()
              robot.listeners.splice(index, 1)

        originLength = robot.listeners.length
        robot.load scriptsPath, msg.match[1]
        callback = ->
          extraListeners = robot.listeners.slice(originLength)
          regexArr = []
          for listener in extraListeners
            regexArr.push(listener.regex.source)
          pathRegMap[path] = regexArr
        setTimeout callback, 1000
        msg.send msg.match[1] + " loaded"
      else
        msg.send "It doesn't exist"
