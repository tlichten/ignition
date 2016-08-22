# ignition

Create MOS on the fly

##### Steps

- Install [Terraform](https://www.terraform.io/downloads.html)
- Register with www.packet.net for an account. **Important:** Use of Packet will incur costs hourly. **Note:** Packet offers discount codes like [the one](https://www.packet.net/promo/coreos/) of the fine folks from [CoreOS](https://coreos.com/) that can get you started
- Obtain Api key token from your packet.net account
- Clone this repo
- Copy ```settings.tf.orig``` to ```settings.tf```
- Set API token in ```settings.tf```
- Then run
```bash
(~/ignition) $ terraform apply .
```
- After deploy, URL for Fuel and Horizon will be provided
- **Important:** When done delete resources to save unnecessary costs:
```bash
(~/ignition) $ terraform destroy .
```
- Verify no servers are still running at packet.net

##### Credits
- [Virl](https://github.com/Snergster/virl_packet) for illustrating use of packet

##### Prior Art
- [Fuel Virtualbox](https://github.com/openstack/fuel-virtualbox)
- [Fuel QA](https://github.com/openstack/fuel-qa)
