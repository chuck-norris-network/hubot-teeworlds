{ Socket } = require 'net';
{ EventEmitter } = require 'events'
split = require 'split'

class TeeworldsConsole extends EventEmitter

  constructor: (@options) ->
    super

    @connection = null

  exec: (message) ->
    return false if !@connection

    # escape command
    [ command ] = message.split ';'

    @connection.write command + '\n'

  say: (message) ->
    lines = message.split '\n'
    @exec "say #{line}" for line in lines

  topic: (strings) ->
    @exec "sv_motd #{strings}"

  handleMessages: (message) =>
    # chat enter
    return @emit 'enter', matches[1] if matches = /^\[chat\]: \*\*\* '([^']+)' entered and joined the (game|spectators)$/.exec message

    # chat leave
    return @emit 'leave', matches[1] if matches = /^\[chat\]: \*\*\* '([^']+)' has left the game$/.exec message

    # chat message
    return @emit 'chat', matches[2], matches[3] if matches = /^\[(teamchat|chat)\]: [0-9]+:[0-9-]+:([^:]+): (.*)$/.exec message

    # authentication request
    return @exec @options.password if message == 'Enter password:'

    # connected
    return @emit 'online' if message == 'Authentication successful. External console access granted.'

  handleEnd: () =>
    @emit 'end'
    @disconnect()

  handleError: (err) =>
    @emit 'error', err

  connect: () ->
    @connection = new Socket();

    @connection
      .pipe split('\n\u0000\u0000')
      .on 'data', @handleMessages
    @connection.on 'end', @handleEnd
    @connection.on 'error', @handleError

    @connection.connect @options.port, @options.host

  disconnect: () ->
    @connection.removeListener 'data', @handleMessages
    @connection.removeListener 'end', @handleMessages
    @connection.removeListener 'error', @handleMessages
    @connection.destroy()
    @connection = null

module.exports = TeeworldsConsole;
