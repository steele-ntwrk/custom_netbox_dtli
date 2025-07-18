# custom_netbox_dtli


custom_netbox_dtli  is a docker imgae builder used to transport NetBox Community Edition and Plugins into a offline enviroment. It also comes with supporting files to help to bring up NetBox and populate it with device-types from DEVICETYPE. 

It works by creating a Docker Image from NetBox Docker using a internet connected host and packinging associated plugin package depenendencies. The image build installs the packages at build time and the `generate_plugin_offline_bundle.sh` script packages the plugins into a tar.gz


## Getting Started

1. Create the folder
```shell
mkdir custom_netbox_dtli
cd custom_netbox_dtli
```
2. Copy the repository 
` git clone https://github.com/steele-ntwrk/custom_netbox_dtli.git `

3. Customie plugin_requirements.txt with your required plugins
```text
django-auth-ldap
netbox-secrets
netbox-topology-views
```
4. Modify netbox.env with your enviroment variables

5. Modify docker-compose.yml to suit your enviroment

6. Run Docker build 
`docker build --no-cache`

7. If using device type libary make sure to amend the permissions to the media folder so netbox can write to when doing device type inport
`sudo chown -R 999:999 ./netbox-media`

8. Update host configuration/plugins.py
```python
PLUGINS = [
        "netbox_secrets",
        "netbox_topology_views"
]
```
9. Bring up the containers 
`docker-compose up -d`

10. Run mandatory scripts for plugins, note this must be done after every container restart 
```cli
docker-compose exec netbox python3 /opt/netbox/netbox/manage.py migrate
	docker-compose exec netbox python3 /opt/netbox/netbox/manage.py collectstatic --no-input



### Optional
I suggest creating a service network to be used for docker containers, this allows to seperate management and service IP addresses. I have provided the general steps I do to create this network using two different vnics

1. Create the static network configuration for both vnics.
```yaml
# /etc/netplan/01-network.yaml
network:
  version: 2
  ethernets:
    ensX:
      dhcp4: false
      addresses:
        - <STATIC_IP>/24
      routes:
        - to: 0.0.0.0/0
          via: <GATEWAY_IP>
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]

    ensY:
      dhcp4: false  # Used as Docker macvlan parent
```
2. Apply the configuration
```cli 
sudo chmod 600 /etc/netplan/01-network.yaml
sudo netplan apply
ip a
```
3. Create docker macvlan network
```cli
docker network create -d macvlan \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  -o parent=ens19 \
  pubMacvlanNet
```
