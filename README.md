# ignition

Create MOS on the fly

##### Steps
- Launch a Centos 7 bare metal instance at [packet.net](http://packet.net)
- Then run
```bash
curl https://raw.githubusercontent.com/tlichten/ignition/master/install.sh | sh
```
- After deploy, Fuel is available at $instance-ip$:8443, Horizon on $instance-ip$:80
