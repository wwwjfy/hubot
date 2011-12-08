Redis = require 'redis'

class Cron
  constructor: ->
    @jobs = []

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
    for msg in self.jobs
      msg.send "blabla"

  incrCounter: ->
    @counter++
    if @counter >= 10
      clearInterval @intervalId
      @run()

  add: (msg) ->
    @jobs.push msg

module.exports = (robot) ->
  cron = new Cron
  cron.run()
