## Context

The sniffing module is written in **Python3** and runs as a service on the Smart Lamp Post APU. It is responsible for capturing probe requests packets and send to a broker values about current devices as well as unique devices that have passed by the post, in real-time. 

## Description

The module uses **PyShark** which is a wrapper for **TShark** (TShark is a terminal based version of wireshark). In order to capture WiFi packets, we turned on monitor mode on wlan1 interface of the APU's wireless network adapter. The PyShark's capture filter is set to probe requests, which are packets that are sent by a device scanning for access points in the area and are sent periodically. From these packets we are able to extract each device's mac address and use it for our statistics purpose.


## Threads

In this file there are 2 running threads and 1 main function running permanently: ***chopping()*** thread, ***run_broker()*** thread and the main function where the PyShark is capturing the packets. 
The first thread, chopping, is responsible for constantly switching wifi channels through 1, 6 and 11. The broker thread implements the producer-side of the broker where the messages are sent and are later consumed by the Web App. 
```python
for channel in channels:
	os.system("iwconfig " + monitor_iface + " channel " + str(channel) + " > /dev/null 2>&1")	
```
The second thread, run_broker, is responsible for sending the sniffing data to the broker
```python
def  main():
	#Chopper Thread
	chopper = threading.Thread(target=chopping)
	chopper.daemon = True
	chopper.start()
	#Broker Thread
	brokerthread = threading.Thread(target=run_broker)
	brokerthread.daemon = True
	brokerthread.start()
	#(...)
```

## Packet Handling

As probe request packets are being captured by PyShark, they are processed by a function, ***packetHandler()***, which filters packets that only are sent by client devices searching for access points in broadcast. Therefore, all AP's sending beacon frames advertising their SSID as well as devices already connected to a certain SSID/access point are all dropped. After this process, the function retrieves the mac address from the packet and marks the current time. This pair of values are saved this in a dictionary and represent the current list of in range devices. Afterward, the same mac address is introduced into the unique devices set, in order to prevent repetitions of the same mac address. In the end of every iteration of this function, another function is called: ***peopleUpdate()*** which goes through the dictionary of the current devices and checks the difference between the current time and the time when each mac address was captured and if the difference is greater than 5 seconds that pair of value stored in the dictionary is removed. 

## Broker

The broker connects to the IP address and a port of the broker installed on the Jetson's post and publishes messages on 2 different topics: **"sniffing/current"** and **"sniffing/unique"**. The first topic is where the current number of devices is published every 5 seconds while the second topic contains the number of unique devices, sent every 10 minutes. 


## Current and Unique Datasets

As previously described, the current devices being detected through Wifi Sniffing are stored until they don't send probe requests for at least 5 seconds. After these 5 seconds they are removed from the list that stores them. These current values are sent to the central broker every 5 seconds, in order to be used by the Web App, showing the number of devices captured in real time.
The unique values are stored before being sent to the central broker, every 10 minutes. This prevents an accumulation of values and of misleading data as one person can pass near the Smart Lamp Posts during the morning and during the afternoon only being counted once. This implementation also allows the calculation of the average unique devices that were detected. In order to achieve this, the code calculates the average of all the captured devices in intervals of 1 minute. After 10 minutes, all values that were stored are excluded from the set. In order to get the  detected values in intervals of 1 hour, the Web App gets the average of all the 10 minutes interval values in that specific hour from the API.

## Configuraration 
### How to configure the lamp post APU wlan1 interface into monitor mode
Make sure **wireless-tools** are installed ```sudo apt install wireless-tools```
```bash
ifconfig wlan1 down
iwconfig wlan1 mode monitor
ifconfig wlan1 up
```
Install **tshark**
```sudo apt install tshark```

Create a python venv and install the requirements
```bash
python3 -m venv venv
source venv\bin\activate
pip install -r requirements.txt
```
To run the module for testing run on the terminal:
```bash
python3 pyshark_ps.py wlan1
```
To run the module on the APU, we need to create a systemd service to do this go to **/etc/systemd/system** and create the file **wifisniffing.service**
```bash
sudo su 
nano /etc/systemd/system/wifisniffing.service
```
and add the following lines to the service:
```bash
[Unit]
Description=Wifi Sniffing Service
After=multi-user.target

[Service]
WorkingDirectory=/root/WiFi_Sniffing
User=root
Type=idle
ExecStart=/root/WiFi_Sniffing/venv/bin/python3 /root/WiFi_Sniffing/pyshark_ps.p$
Restart=always

[Install]
WantedBy=multi-user.target
```
Finally we need to run the service, to do this on the terminal run:
```bash
sudo su 
systemctl daemon-reload
systemctl start wifisniffing
```
check if the service is **active**:
```bash
systemctl status wifisniffing
```
if you change the code but the service is already created do:
```bash
systemctl restart wifisniffing
systemctl status wifisniffing
```






