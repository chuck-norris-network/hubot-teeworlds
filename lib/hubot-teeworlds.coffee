TeeworldsEcon = require 'teeworlds-econ'
{ PickupMessage, KillMessage } = require './messages'
{ HammerWeapon, GunWeapon, ShotgunWeapon, RocketWeapon, LaserWeapon, KatanaWeapon } = require './weapons'
try
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = prequire 'hubot'

class TeeworldsAdapter extends Adapter

  constructor: (robot) ->
    super

    @server = {
      host:     process.env['HUBOT_TW_HOST']
      port:     parseInt process.env['HUBOT_TW_PORT']
      password: process.env['HUBOT_TW_PASSWORD']
    }

    unless @server.host and @server.port and @server.password
      throw new Error('Undefined Teeworlds configuration variables')

    @econ = new TeeworldsEcon @server.host, @server.port, @server.password

  send: (envelope, messages...) ->
    @econ.say message for message in messages

  reply: (envelope, messages...) ->
    @econ.say "#{envelope.user.name}: #{message}" for message in messages

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

  pickup: (from, item) =>
    @robot.logger.debug "#{from} picked #{item}"

    switch item
      when 'shotgun' then weapon = new ShotgunWeapon
      when 'rocket' then weapon = new RocketWeapon
      when 'laser' then weapon = new LaserWeapon
      when 'katana' then weapon = new KatanaWeapon
      else return

    user = new User from
    message = new PickupMessage user, weapon

    @receive message

  kill: (from, whom, item) =>
    @robot.logger.debug "#{from} killed #{whom} with #{item}"

    # suicide
    return if from == whom

    switch item
      when 'hammer' then weapon = new HammerWeapon
      when 'gun' then weapon = new GunWeapon
      when 'shotgun' then weapon = new ShotgunWeapon
      when 'rocket' then weapon = new RocketWeapon
      when 'laser' then weapon = new LaserWeapon
      when 'katana' then weapon = new KatanaWeapon
      else return

    user = new User from
    victim = new User whom
    message = new KillMessage user, victim, weapon

    @receive message

  topic: (envelope, strings...) ->
    @econ.motd strings.join '\n'

  run: () ->
    @econ.on 'online', () =>
      @emit 'connected'
      @robot.logger.info 'Hubot online'

    @econ.on 'reconnected', () =>
      @robot.logger.info 'Reconnected'
      @emit 'reconnected'

    @econ.on 'error', (err) =>
      @robot.logger.error err.message

    @econ.on 'reconnect', () =>
      @robot.logger.info 'Connection error, attempting to reconnect'

    @econ.on 'chat', @chat
    @econ.on 'enter', @enter
    @econ.on 'leave', @leave
    @econ.on 'pickup', @pickup
    @econ.on 'kill', @kill

    @econ.connect()

module.exports = TeeworldsAdapter
