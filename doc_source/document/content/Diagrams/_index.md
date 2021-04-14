## Domain diagram

The domain model of the project represents the real-world conceptual classes of the system, their attributes and how they are associated.

<div style="text-align:center"><img src="domain.png" /></div>

## Use Case diagrams

<div style="text-align:center"><img src="useCases1.png" /></div>

<div style="text-align:center"><img src="useCases2.png" /></div>

## Architecture diagram

The data relative to the number of people detected by Wi-Fi sniffing and object detection and the number of moliceiros detected by object detection is captured by the respective modules in the sensors and this data is sent to the broker through a MQTT connection. The broker saves the data in a database and also sends it to the Web service (Flask). The web server (Gunicorn) interacts with the Web service and communicates with the Reverse Proxy Server (Nginx) through a Unix socket. The Reverse Proxy Server manages the load balance of requests. The user visualizes the web application in his device, sending and receiving HTTPS requests and responses.

<div style="text-align:center"><img src="arquitetura_withbg.png" /></div>

## Deployment diagram

In this diagram it is possible to view the several components of the system and how they interact between them.

<div style="text-align:center"><img src="deployment_withbg.png" /></div>
