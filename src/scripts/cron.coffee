# Cron job
#
# schedule at 10:30 once/every weekday/everyday <command> - ask the bot to execute <command> at 10:30 every weekday or everyday
# show schedules - show schedules with id and description
# cancel schedule <id> - cancel schedule by the id shown in "show schedules"

Redis = require 'redis'
Robot = require '../robot'

class Cron
  constructor: (@robot) ->
    @jobs = []

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.schedule
        @jobs = @robot.brain.data.schedule
      @resetJobId()

  resetJobId: ->
    @jobId = 0
    for job in @jobs
      @jobId++
      job.id = @jobId

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
        if job.date == "every weekday" && (date.getDay() == 0 || date.getDay() == 6)
          continue
        self.robot.adapter.receive new Robot.TextMessage(job.user, self.robot.name + ': ' + job.action)
        if job.date == "once"
          self.cancel job.id

  incrCounter: ->
    @counter++
    if @counter >= 10
      clearInterval @intervalId
      @run()

  add: (hour, min, date, action, msg) ->
    @resetJobId()
    @jobId++
    job = 'hour': hour, 'min': min, 'date': date, 'action': action, 'user': msg.message.user, 'id': @jobId
    @jobs.push job
    @robot.brain.data.schedule = @jobs
    job

  cancel: (jobId) ->
    for id, job of @jobs
      if job.id == jobId
        @jobs.splice(id, 1)
        @resetJobId()
        return
    return false

  getJobs: ->
    @jobs

  getJobDesc: (job) ->
    hour = if job.hour < 9 then "0" + job.hour else job.hour
    min = if job.min < 9 then "0" + job.min else job.min
    job.action + ' at ' + hour + ':' + min + ' ' + job.date

module.exports = (robot) ->
  cron = new Cron robot
  cron.run()

  robot.respond /schedule at ([0-9]{1,2}):([0-9]{1,2}) (once|every weekday|everyday) (.*)$/i, (msg) ->
    hour = parseInt msg.match[1]
    min = parseInt msg.match[2]
    date = msg.match[3]
    action = msg.match[4]

    # data validation
    if hour > 23
      msg.send msg.message.user.name + ": I can only count 0 to 23 as hour.."
      return
    if min > 60
      msg.send msg.message.user.name + ": I can only count 0 to 60 as minute.."
      return

    job = cron.add(hour, min, date, action, msg)

    msg.send "Got it and it's already in my mind. Repeat it again: " + cron.getJobDesc job

  robot.respond /show schedules/i, (msg) ->
    for job in cron.getJobs()
      msg.send job.id + ': ' + cron.getJobDesc job

  robot.respond /cancel schedule ([0-9]+)$/i, (msg) ->
    if false == cron.cancel parseInt msg.match[1]
      msg.send msg.message.user.name "Hey, stop kidding me. I don't remember that."
    else
      msg.send "Fine, I've already forgotten it."
