# Ethical Hacking Lab

This repository contains a Docker Compose configuration to set up the required Docker containers for the Ethical Hacking Lab. This environment provides a comprehensive set of tools and services for hands-on learning and experimentation in network security.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Docker
- Docker Compose

## Getting Started

1. Clone this repository:

   ```
   git clone https://github.com/michaelborck-education/ethical-hacking-lab.git
   ```

2. Navigate to the cloned repository:

   ```
   cd ethical-hacking-lab
   ```

3. Start the Docker environment:

   ```
   docker-compose up -d
   ```

   This command will download the necessary images and start all the containers.

   **Note:** The initial setup may take several minutes to complete, as Docker needs to pull all the required images. Subsequent starts will be much quicker, typically taking only a few seconds to bring up or down the entire environment.

4. Once all containers are running, you can access the various services as described in the "Available Services" section below.

## Available Services

| Service Name   | Description                                            | Access Method                                           |
|----------------|--------------------------------------------------------|----------------------------------------------------------|
| Wireshark      | Network protocol analyser                              | `http://localhost:3000`                                  |
| Workstation    | Basic Alpine Linux workstation                         | `docker exec -it workstation sh`                         |
| SecUtils       | Basic security utilities                               | `docker exec -it secutils sh`                            |
| Netshoot       | Network troubleshooting container                      | `docker exec -it netshoot sh`                            |
| Ubuntu Desktop | Ubuntu LXDE desktop environment                        | VNC: `localhost:5900`<br>NoVNC (browser): `http://localhost:6080` |
| OpenLDAP       | LDAP server                                            | `ldap://localhost:389`                                   |
| MailHog        | Email testing tool                                     | `http://localhost:8025`                                  |
| MySQL          | MySQL database server                                  | `mysql -h localhost -P 3306 -u user -p`                  |
| Telnet         | Telnet server                                          | `telnet localhost 23`                                    |
| OWASP Juice Shop | Web application security training platform           | `http://localhost:3012`                                  |
| DVWA           | Damn Vulnerable Web Application                        | `http://localhost:8085`                                  |

## Usage Guidelines

1. **Wireshark**: Access the web-based Wireshark interface to analyse network traffic.

2. **Workstation, SecUtils, and Netshoot**: Use these containers for various command-line operations and network troubleshooting. Access them using the `docker exec` command as shown in the table above.

3. **Ubuntu Desktop**: Connect using a VNC client or access via a web browser for a graphical Linux environment.

4. **OpenLDAP**: Use this for experimenting with LDAP authentication and directory services.

5. **MailHog**: A useful tool for testing email functionality without sending real emails.

6. **MySQL**: Practice database security concepts and SQL injection prevention.

7. **Telnet**: Use for learning about insecure protocols and practising secure alternatives.

8. **OWASP Juice Shop and DVWA**: These intentionally vulnerable web applications are excellent for practising web application security techniques.

## Security Notice

This environment contains intentionally vulnerable applications and services for educational purposes. Do not deploy this in a production environment or on a public network. Always use this setup in a controlled, isolated environment.

## Troubleshooting

If you encounter any issues:

1. Ensure all containers are running:
   ```
   docker-compose ps
   ```

2. Check container logs:
   ```
   docker-compose logs [service_name]
   ```

3. Restart the environment:
   ```
   docker-compose down
   docker-compose up -d
   ```

## Contributing

We welcome contributions to improve this learning environment. Please submit pull requests or open issues on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
