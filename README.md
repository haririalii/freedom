# FREEDOM
Shadowsocks + v2ray plugin (HTTP) installation script. One of the rare ways to bypass the Iranian government's internet censorship
> According to the [v2ray-plugin](https://github.com/shadowsocks/v2ray-plugin), HTTP only provides moderate (but lightweight) traffic obfuscation. Cautious users should refrain from using this mode.
# Requirement:
+ Ubuntu server
# Installation and usage:
First, make scripts executable:
```bash
chmod +x ss-server.sh v2ray.sh
```
then, run the script:
```bash
./ss-server
```
Now you can run Shadowsocks + v2ray server using the following command:
```bash
ss-server -c {path_to_config} start
```
