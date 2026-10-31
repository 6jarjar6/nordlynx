After [installing Wireguard](https://github.com/runfalk/synology-wireguard) on synology, the following variables need to be set appropriately for `nordlynx` to work:

- `ALLOWED_IPS=0.0.0.0/1,128.0.0.0/1`
- `"POST_UP=ip -4 route add $$(wg | awk -F'[: ]' '/endpoint/ {print $$5}') via $$(ip route | awk '/default/ {print $$3}')"`
- `"PRE_DOWN=ip -4 route del $$(route -n | awk '/255.255.255.255/ {print $$1}') via $$(ip route | awk '/default/ {print $$3}')"`

The above settings _extend_ the required configuration that is described in the README (e.g. one also has to provide the `ALLOWED_IPS`).

Clarification:
- `ALLOWED_IPS` can not be `0.0.0.0/0` for Synology, so we split the full range into two halves.
- `POST_UP` adds a route for directing all traffic to the NordVPN server endpoint to the gateway (otherwise it gets stuck).
- `PRE_DOWN` removes the custom route above (needed for reconnect). Since the endpoint may have changed during the connection, we cannot extract its address from `wg` like we did in `POST_UP`.

Further clarification is provided in https://github.com/bubuntux/nordlynx/discussions/41, which is also open for suggestions to improve the setup.