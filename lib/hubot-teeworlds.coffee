{ Socket } = require('net');

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

  send: (envelope, messages...) =>
    messages.forEach (message) =>
      @conn.write "say #{line}\n" for line in message.split '\n'

  reply: (envelope, messages...) =>
    messages.forEach (message) =>
      @conn.write "say #{envelope.user.name}: #{line}\n" for line in message.split '\n'

  parseData: (buf) =>
    str = buf.toString 'utf8'

    matches = /\[chat\]: [0-9]+:[0-9\-]+:([^:]+): (.*)/g.exec str
    return unless matches

    [ from, message ] = matches[1..2]

    @robot.logger.debug "Received message: #{message} from: #{from}"

    user = new User from
    message = new TextMessage(user, message)

    @receive message

  run: () =>
    @conn = new Socket();

    @conn.on 'data', @parseData

    @conn.connect @options.port, @options.host, () =>
      @conn.write @options.password + '\n'

    @emit "connected"
    @robot.logger.info 'Hubot online'

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
