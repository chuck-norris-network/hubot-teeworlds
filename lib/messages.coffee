try
  { Message } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Message } = prequire 'hubot'

class PickupMessage extends Message
  constructor: (@user, @weapon) ->
    super @user

class KillMessage extends Message
  constructor: (@user, @victim, @weapon) ->
    super @user

module.exports = {
  PickupMessage
  KillMessage
}
