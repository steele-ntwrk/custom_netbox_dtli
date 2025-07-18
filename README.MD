
# custom_netbox_dtli

`custom_netbox_dtli` is a Docker image builder used to transport **NetBox Community Edition** and associated plugins into an offline environment. It includes supporting files to help bring up NetBox and populate it with device types from the [Device Type Library](https://github.com/netbox-community/devicetype-library).

It works by creating a custom Docker image from the official NetBox Docker image using an internet-connected host. During the build, plugin dependencies are installed, and the `generate_plugin_offline_bundle.sh` script packages them into a `.tar.gz` bundle for offline use.

---

## Getting Started

1. **Create a working directory**
   ```bash
   mkdir custom_netbox_dtli
   cd custom_netbox_dtli
   ```

2. **Clone the repository**
   ```bash
   git clone https://github.com/steele-ntwrk/custom_netbox_dtli.git .
   ```

3. **Customize the plugin requirements**
   Edit `plugin_requirements.txt` with the list of required plugins:
   ```text
   django-auth-ldap
   netbox-secrets
   netbox-topology-views
   ```

4. **Modify environment variables**
   Update `netbox.env` with your environment-specific settings.

5. **Edit Docker Compose file**
   Modify `docker-compose.yml` to match your environment (e.g., volumes, ports, networks).

6. **Build the Docker image**
   ```bash
   docker build --no-cache -t custom_netbox_dtli .
   ```

7. **Fix media permissions** (required for device-type import)
   ```bash
   sudo chown -R 999:999 ./netbox-media
   ```

8. **Update plugin configuration**
   Modify the `plugins.py` file in the host configuration:
   ```python
   PLUGINS = [
       "netbox_secrets",
       "netbox_topology_views"
   ]
   ```

9. **Start the containers**
   ```bash
   docker-compose up -d
   ```

10. **Run mandatory NetBox plugin setup (after *every* container restart)**
    ```bash
    docker compose exec netbox python3 /opt/netbox/netbox/manage.py migrate
    docker compose exec netbox python3 /opt/netbox/netbox/manage.py collectstatic --no-input
    ```

11. **Import device types**
    ```bash
    ./import-devices.sh
    ```

---

## Offline Deployment

To move the image and plugin bundle to an offline environment:

1. Transfer the following to the offline host:
   - The custom Docker image (via `docker save`)
   - The `.tgz` bundle created by:
     ```bash
     bash generate_plugin_offline_bundle.sh
     ```
   - The files in this repository (either copy or re-download)

---

## Optional: Macvlan Network Configuration

For better network isolation, you may choose to create a dedicated service network using Docker macvlan and separate vNICs. Below are general steps using `netplan`.

1. **Configure static IPs for both interfaces**

   File: `/etc/netplan/01-network.yaml`
   ```yaml
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

2. **Apply netplan config**
   ```bash
   sudo chmod 600 /etc/netplan/01-network.yaml
   sudo netplan apply
   ip a
   ```

3. **Create Docker macvlan network**
   ```bash
   docker network create -d macvlan      --subnet=192.168.100.0/24      --gateway=192.168.100.1      -o parent=ensY      pubMacvlanNet
   ```

---


---

## Resources

- NetBox Project: [https://netbox.dev](https://netbox.dev)
- NetBox GitHub Repository: [https://github.com/netbox-community/netbox](https://github.com/netbox-community/netbox)

---
