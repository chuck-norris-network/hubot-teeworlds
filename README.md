# Hubot Teeworlds Adapter

[![NPM version][npm-image]][npm-url] [![Dependency Status][daviddm-image]][daviddm-url]

Connects Hubot to your [Teeworlds](https://www.teeworlds.com/) game server.

## Getting started

1. Configure Teeworlds external console. See [Teeworlds configuration](#teeworlds-configuration) section.
2. Install adapter: `$ npm install --save hubot-teeworlds`.
3. Set the environment variables specified in [Hubot configuration](#hubot-configuration) section.
4. Run Hubot: `$ bin/hubot -a teeworlds`.

## Teeworlds configuration

Add the following lines to Teeworlds server config:

```
ec_port         8303
ec_password     secret
ec_output_level 2
```

Restart server and test connection using telnet or ncat: `$ telnet localhost 8303`.

## Hubot configuration

The adapter requires the following environment variables:

* `HUBOT_TW_HOST` — IP address or FQDN of Teeworlds server
* `HUBOT_TW_PORT` — external console port
* `HUBOT_TW_PASSWORD` — external console password

## License

MIT © [Black Roland](https://github.com/black-roland)

[npm-image]: https://badge.fury.io/js/hubot-teeworlds.svg
[npm-url]: https://www.npmjs.com/package/hubot-teeworlds
[daviddm-image]: https://david-dm.org/black-roland/hubot-teeworlds.svg?theme=shields.io
[daviddm-url]: https://david-dm.org/black-roland/hubot-teeworlds
