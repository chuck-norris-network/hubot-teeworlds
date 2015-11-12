{ Adapter, TextMessage, User } = require 'hubot'
{ Socket } = require('net');

class TeeworldsAdapter extends Adapter

  constructor: (robot) ->
    super

    @options =
      host:     process.env['HUBOT_TW_HOST']
      port:     parseInt process.env['HUBOT_TW_PORT']
      password: process.env['HUBOT_TW_PASSWORD']

  parseData: (buf) =>
    str = buf.toString 'utf8'

    matches = /\[chat\]: [0-9]+:[0-9\-]+:([^:]+): (.*)/g.exec str
    return unless matches

    [ user, msg ] = matches[1..2]

    @robot.logger.info user, msg

  connect: () =>
    @conn = new Socket();

    @conn.on 'data', @parseData

    @conn.connect @options.port, @options.host, () =>
      @conn.write @options.password + '\n'

  run: () =>
    @connect()

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
