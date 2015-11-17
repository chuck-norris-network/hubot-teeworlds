{ Socket } = require 'net'
{ EventEmitter } = require 'events'
split = require 'split'

class TeeworldsConsole extends EventEmitter

  constructor: (@options) ->
    super

    @connection = null

  exec: (command) ->
    if !@connection
      @emit 'error', new Error 'Not connected'
      return

    @connection.write command + '\n'

  say: (message) ->
    # split multiline message
    lines = message.split '\n'

    # split long messages to chunks
    chunks = []
    for line in lines
      chunks = chunks.concat line.match(/.{1,100}/g)

    # execute say command
    @exec "say #{@escape chunk}" for chunk in chunks

  topic: (topic) ->
    @exec "sv_motd #{@escape topic}"

  escape: (string) ->
    # escape quotes
    string = string.replace /"/g, '\\"'

    # escape line breaks
    string = string.replace /\n/g, '\\n'

    return '"' +  string + '"'

  handleMessages: (message) =>
    # coffeelint: disable=max_line_length

    # chat enter
    if matches = /^\[chat\]: \*\*\* '([^']+)' entered and joined the.*/.exec message
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
    return if @connection

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
