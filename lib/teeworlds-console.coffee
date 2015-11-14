{ Socket } = require 'net'
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
    @exec "sv_motd #{strings.replace(/\n/g, '\\n')}"

  handleMessages: (message) =>
    # coffeelint: disable=max_line_length

    # chat enter
    if matches = /^\[chat\]: \*\*\* '([^']+)' entered and joined the (game|spectators)$/.exec message
      return @emit 'enter', matches[1]

    # chat leave
    if matches = /^\[chat\]: \*\*\* '([^']+)' has left the game.*/.exec message
      return @emit 'leave', matches[1]

    # chat message
    if matches = /^\[(teamchat|chat)\]: [0-9]+:[0-9-]+:([^:]+): (.*)$/.exec message
      return @emit 'chat', matches[2], matches[3]

    # authentication request
    if message == 'Enter password:'
      return @exec @options.password

    # connected
    if message == 'Authentication successful. External console access granted.'
      return @emit 'online'

    # wrong password
    if /^Wrong password [0-9\/]+.$/.exec message
      @emit 'error', new Error "#{message} Disconnecting"
      return @disconnect()

    # authentication timeout
    if message == 'authentication timeout'
      @emit 'error', new Error 'Authentication timeout. Disconnecting'
      return @disconnect()

    # coffeelint: enable=max_line_length

  connect: () ->
    return false if @connection

    @connection = new Socket()

    @connection
      .pipe split('\n\u0000\u0000')
      .on 'data', @handleMessages

    @connection.on 'error', (err) =>
      @emit 'error', err
    @connection.on 'close', @disconnect
    @connection.on 'end', @disconnect

    @connection.setKeepAlive true

    @connection.connect @options.port, @options.host

  disconnect: () =>
    return if !@connection

    @connection.removeAllListeners 'data'
    @connection.removeAllListeners 'end'
    @connection.removeAllListeners 'error'
    @connection.destroy()
    @connection.unref()
    @connection = null
    @emit 'end'

module.exports = TeeworldsConsole
