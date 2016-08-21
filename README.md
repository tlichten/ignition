# ignition

Create MOS on the fly

##### Steps
- Launch a Centos 7 bare metal instance at [packet.net](http://packet.net)
- Then run
```bash
curl https://raw.githubusercontent.com/tlichten/ignition/master/install.sh | sh
```
- After deploy, Fuel is available at $instance-ip$:8443, Horizon on $instance-ip$:80


##### Credits
- [Virl](https://github.com/Snergster/virl_packet) for illustrating use of packet

##### Prior Art
- [Fuel Virtualbox](https://github.com/openstack/fuel-virtualbox)
- [Fuel QA](https://github.com/openstack/fuel-qa) 
