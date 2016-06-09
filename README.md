# ignition

A virtualized Mirantis Fuel and OpenStack lab on demand to be provisioned on bare metal as a service, e.g. packet.net.

##### Goal
Spin up turn-key lab environments that are either predefined examples or can be customized for demo, learning, functional validation purposes.

##### Steps
- Launch Type 3 (large) Centos 7 bare metal instance at packet.net
```bash
curl https://raw.githubusercontent.com/tlichten/ignition/master/install.sh | sh
```
