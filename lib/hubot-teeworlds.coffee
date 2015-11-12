TeeworldsConsole = require './teeworlds-console'

try
  { Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, User } = prequire 'hubot'

class TeeworldsAdapter extends Adapter

  constructor: (robot) ->
    super

    @options =
      host:     process.env['HUBOT_TW_HOST']
      port:     parseInt process.env['HUBOT_TW_PORT']
      password: process.env['HUBOT_TW_PASSWORD']

    @console = new TeeworldsConsole @options;

  send: (envelope, messages...) ->
    @console.say message for message in messages

  reply: (envelope, messages...) ->
    @console.say "#{envelope.user.name}: #{message}" for message in messages

  chat: (from, text) =>
    @robot.logger.debug "Received message: #{from}: #{text}"

    user = new User from
    message = new TextMessage user, text

    @receive message

  run: () ->
    @console.on 'online', () =>
      @emit 'connected'
      @robot.logger.info 'Hubot online'

    @console.on 'chat', @chat

    # @console.on 'enter', (user) ->
    #   console.log 'Enter', user
    #
    # @console.on 'leave', (user) ->
    #   console.log 'Leave', user

    @console.connect()

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
