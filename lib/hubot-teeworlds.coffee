TeeworldsEcon = require 'teeworlds-econ'
{ PickupMessage, KillMessage } = require './messages'
{ HammerWeapon, GunWeapon, ShotgunWeapon, RocketWeapon, LaserWeapon, KatanaWeapon } = require './weapons'
{ parseServers } = require './utils'
try
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, EnterMessage, LeaveMessage, User } = prequire 'hubot'

class TeeworldsAdapter extends Adapter

  constructor: (robot) ->
    super

    @servers = parseServers process.env['HUBOT_TW_SERVERS']
    throw new Error('Can\'t parse HUBOT_TW_SERVERS') unless @servers

    @consoles = @setupConsoles @servers

  send: (envelope, messages...) ->
    hostname = envelope.hostname ? envelope.user?.hostname ? envelope.room
    econ = @consoles[hostname]

    unless econ
      @robot.logger.warning 'Can\'t send message: hostname not found'
      return

    for message in messages
      @robot.logger.debug "Sending to #{hostname}: #{message}"
      econ.say message

  reply: (envelope, messages...) ->
    @send envelope, "#{envelope.user.name}: #{message}" for message in messages

  topic: (envelope, strings...) ->
    for hostname, econ of @consoles
      econ.motd strings.join '\n'

  onChat: (hostname, from, text) =>
    @robot.logger.debug "Received message: #{from}: #{text}"

    user = new User from, { hostname, room: hostname }
    message = new TextMessage user, text

    @receive message

  onEnter: (hostname, from) =>
    @robot.logger.debug "#{from} joined to #{hostname}"

    user = new User from, { hostname, room: hostname }
    message = new EnterMessage user

    @receive message

  onLeave: (hostname, from) =>
    @robot.logger.debug "#{from} leaved from #{hostname}"

    user = new User from, { hostname, room: hostname }
    message = new LeaveMessage user

    @receive message

  onPickup: (hostname, from, item) =>
    @robot.logger.debug "#{from} picked #{item} on #{hostname}"

    switch item
      when 'shotgun' then weapon = new ShotgunWeapon
      when 'rocket' then weapon = new RocketWeapon
      when 'laser' then weapon = new LaserWeapon
      when 'katana' then weapon = new KatanaWeapon
      else return

    user = new User from, { hostname, room: hostname }
    message = new PickupMessage user, weapon

    @receive message

  onKill: (hostname, from, whom, item) =>
    @robot.logger.debug "#{from} killed #{whom} with #{item} on #{hostname}"

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

    user = new User from, { hostname, room: hostname }
    victim = new User whom, { hostname, room: hostname }
    message = new KillMessage user, victim, weapon

    @receive message

  setupConsoles: (servers) ->
    consoles = {}

    for hostname, server of servers
      do (hostname, server) =>
        econ = new TeeworldsEcon server.host, server.port, server.password

        econ.on 'online', () =>
          @emit 'connected', server
          @robot.logger.info 'Connected to %s', hostname

        econ.on 'reconnected', () =>
          @robot.logger.info 'Reconnected to %s', hostname
          @emit 'reconnected', server

        econ.on 'error', (err) =>
          @robot.logger.error err.message, hostname

        econ.on 'reconnect', () =>
          @robot.logger.info 'Connection to %s lost, attempting to reconnect', hostname

        econ.on 'chat', @onChat.bind(null, hostname)
        econ.on 'enter', @onEnter.bind(null, hostname)
        econ.on 'leave', @onLeave.bind(null, hostname)
        econ.on 'pickup', @onPickup.bind(null, hostname)
        econ.on 'kill', @onKill.bind(null, hostname)

        consoles[hostname] = econ

    return consoles

  run: () ->
    for hostname, econ of @consoles
      econ.connect()

module.exports = TeeworldsAdapter
