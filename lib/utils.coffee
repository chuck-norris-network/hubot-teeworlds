module.exports.parseServers = (serversString) ->
  return null unless serversString

  servers = {}

  items = serversString.split ','

  for item in items
    [ host, port, password ] = item.split ':'
    return null unless host and port and password
    servers[host + ':' + port] = { host, port, password }

  return servers
