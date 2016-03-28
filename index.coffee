TeeworldsAdapter = require './lib/hubot-teeworlds'
{ PickupMessage, KillMessage } = require './lib/messages'
{ Weapon, HammerWeapon, GunWeapon, ShotgunWeapon, RocketWeapon, LaserWeapon, KatanaWeapon } = require './lib/weapons'

module.exports = {
  TeeworldsAdapter
  PickupMessage
  KillMessage
  Weapon
  HammerWeapon
  GunWeapon
  ShotgunWeapon
  RocketWeapon
  LaserWeapon
  KatanaWeapon
}

module.exports.use = (robot) ->
  new TeeworldsAdapter robot
