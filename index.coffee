TeeworldsAdapter = require './lib/hubot-teeworlds'
{ PickupMessage, KillMessage } = require './lib/messages'
{ Weapon, Hammer, Gun, Shotgun, Rocket, Laser, Katana } = require './lib/weapons'

module.exports = {
  TeeworldsAdapter
  PickupMessage
  KillMessage
  Weapon
  Hammer
  Gun
  Shotgun
  Rocket
  Laser
  Katana
}

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
