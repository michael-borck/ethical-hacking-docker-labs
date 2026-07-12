# Docker Compose: Network Security Toolkit

This repository contains a `docker-compose.yaml` file that sets up a Network Security Toolkit with HAProxy, Wireshark, and Security Utilities. The provided `docker-compose.yaml` file creates a custom Docker network and connects all services to it.

## Services

1. **proxy** (HAProxy): A high-performance and highly-robust TCP/HTTP load balancer. The configuration file is mapped from the local `haproxy.cfg` file.
2. **wireshark** (ffeldhaus/wireshark): A Docker container running Wireshark with Xpra for remote access. It is connected to the proxy service and uses the same network.
3. **attacker** (ghcr.io/michael-borck/ethical-base): The shared Kali-based attacker workstation with the command-line security tools (nmap, hydra, nikto, netcat, curl, and more).

## Usage

1. Install [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/).
2. Clone this repository:
```
git clone https://github.com/michael-borck/ethical-hacking-docker-labs.git
```
3. Change to this lab's directory:
```
cd ethical-hacking-docker-labs/labs/week1
```
4. Create and start the services with Docker Compose:
```
docker-compose up -d
```

## Service Configuration

### Proxy (HAProxy)

- **IP address**: 192.168.1.2
- **Port**: 14500
- **Configuration file**: `./haproxy.cfg`

### Wireshark

- **IP address**: 192.168.1.3
- **Access password**: "wireshark"
- **Captured files**: Stored in the local `./caps` directory

### Attacker Workstation

- **Image**: `ghcr.io/michael-borck/ethical-base`
- **Container name**: `week1-attacker`
- **Tools**: nmap, hydra, nikto, netcat, curl, and the rest of the CLI toolkit

## Custom Network Configuration

- **Network name**: custom_network
- **Driver**: bridge
- **Subnet**: 192.168.1.0/24

## Stopping and Removing Services

To stop and remove the services, use the following command:

```
docker-compose down
```

## Connecting to the Wireshark Container

To access the Wireshark container remotely, follow these steps:

1. Open your web browser and go to `http://localhost:14500`.

2. You will be prompted to enter the Xpra username and password. Use the following credentials:

   - **Username**: wireshark
   - **Password**: wireshark

3. After successful authentication, you will be able to access the Wireshark interface remotely.

Please note that the Wireshark container is connected to the proxy service, which listens on port 14500. Make sure the proxy service is up and running before attempting to connect to the Wireshark container.

## Connecting to the Attacker Workstation

Open a terminal and run the following command to get a shell on the Kali-based
attacker box, where the command-line security tools are installed:

```
docker exec -it week1-attacker bash
```

From here you can use nmap, hydra, nikto, netcat, curl, and more. If you launched
the lab with `./start.sh`, just type `connect` instead.

## License

This project is released under the MIT License. See the [LICENSE](LICENSE) file for details.
