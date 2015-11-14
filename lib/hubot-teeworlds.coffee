TeeworldsConsole = require './teeworlds-console'

try
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = prequire 'hubot'

class TeeworldsAdapter extends Adapter

  reconnectInterval: 30000

  constructor: (robot) ->
    super

    @options =
      host:     process.env['HUBOT_TW_HOST']
      port:     parseInt process.env['HUBOT_TW_PORT']
      password: process.env['HUBOT_TW_PASSWORD']

    @connected = false

    @console = new TeeworldsConsole @options

  send: (envelope, messages...) ->
    @console.say message for message in messages

  reply: (envelope, messages...) ->
    @console.say "#{envelope.user.name}: #{message}" for message in messages

  chat: (from, text) =>
    @robot.logger.debug "Received message: #{from}: #{text}"

    user = new User from
    message = new TextMessage user, text

    @receive message

  enter: (from) =>
    @robot.logger.debug "#{from} joined"

    user = new User from
    message = new EnterMessage user

    @receive message

  leave: (from) =>
    @robot.logger.debug "#{from} leaved"

    user = new User from
    message = new LeaveMessage user

    @receive message

  topic: (envelope, strings...) ->
    @console.topic strings.join '\n'

  reconnect: () ->
    setTimeout () =>
      @robot.logger.info 'Reconnecting...'
      @console.connect()
    , @reconnectInterval

  run: () ->
    @console.on 'online', () =>
      @emit if @connected then 'reconnected' else 'connected'
      @connected = true
      @robot.logger.info 'Hubot online'

    @console.on 'error', (err) =>
      @robot.logger.error err.message

    @console.on 'end', () =>
      @robot.logger.info 'Connection error, attempting to reconnect'
      @reconnect()

    @console.on 'chat', @chat
    @console.on 'enter', @enter
    @console.on 'leave', @leave

    @console.connect()

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
