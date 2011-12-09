Redis = require 'redis'
Robot = require '../robot'

class Cron
  constructor: (@robot) ->
    @jobs = []

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.schedule
        @jobs = @robot.brain.data.schedule

  run: ->
    @resetTimer()

  resetTimer: ->
    @counter = 0
    runCron = (self) ->
      self.runCronJobs(self)
      self.intervalId = setInterval self.runCronJobs, 60 * 1000, self
    setTimeout runCron, (60 - new Date().getSeconds()) * 1000, @

  runCronJobs: (self) ->
    self.incrCounter()
    for job in self.jobs
      date = new Date()
      if date.getHours() == job.hour && date.getMinutes() == job.min
        if job.date == 'every weekday' && (date.getDay() == 0 || date.getDay() == 6)
          continue
        self.robot.adapter.receive new Robot.TextMessage(job.user, self.robot.name + ': ' + job.action)

  incrCounter: ->
    @counter++
    if @counter >= 10
      clearInterval @intervalId
      @run()

  add: (hour, min, date, action, msg) ->
    job = {'hour': hour, 'min': min, 'date': date, 'action': action, 'user': msg.message.user}
    @jobs.push job
    @robot.brain.data.schedule = @jobs

module.exports = (robot) ->
  cron = new Cron robot
  cron.run()

  robot.respond /schedule at ([0-9]{1,2}):([0-9]{1,2}) (every weekday|everyday) (.*)$/, (msg) ->
    hour = parseInt(msg.match[1])
    min = parseInt(msg.match[2])
    date = msg.match[3]
    action = msg.match[4]

    # data validation
    if hour > 23
      msg.send msg.message.user.name + ": I can only count 0 to 23 as hour.."
      return
    if min > 60
      msg.send msg.message.user.name + ": I can only count 0 to 60 as minute.."
      return

    cron.add(hour, min, date, action, msg)
