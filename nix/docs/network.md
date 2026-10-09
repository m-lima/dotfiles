# Web traffic network

## External

The firewall and router allow port 80 and 443. However, for TLS, it remaps the incoming 443 traffic to a special port internally. Only one host is the gateway for web traffic into the internal network.

## Internal

The web servers in each internal host serve 80, 443, and the special port.
Port 80 is what it is, nothing special.
Port 443 is used solely for internal traffic and requests, so that the host can be reached internally with TLS without having to specify the special port.
The special port serves proxy_protocol traffic.

The gateway is responsible for serving a stream that either redirects to the local host or to other hosts in the internal network using proxy_protocol.

## Proxy protocol

Because nginx uses the Host header for routing, it needs to decrypt and terminate the TLS connection in the frontend. For that, it needs a lightweight protocol to inject the original request information. This is the proxy protocol.
