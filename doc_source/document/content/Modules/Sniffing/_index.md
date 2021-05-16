## Context

The sniffing module is written in **Python3** and runs as a service on the Smart Lamp Post APU. It is responsible for capturing probe requests packets and send to a broker values about current devices as well as unique devices that have passed by the post, in real-time. 

## Description

The module uses **PyShark** which is a wrapper for **TShark** (TShark is a terminal based version of wireshark). In order to capture WiFi packets, we turned on monitor mode on wlan1 interface of the APU's wireless network adapter. The PyShark's capture filter is set to probe requests, which are packets that are sent by a device scanning for access points in the area and are sent periodically. From these packets we are able to extract each device's mac address and use it for our statistics purpose.

### How to configure the lamp post APU wlan1 interface into monitor mode
```bash
ifconfig wlan1 down
iwconfig wlan1 mode monitor
ifconfig wlan1 up
```

## Threads

In this file there are 2 running threads and 1 main function running permanently: ***chopping()*** thread, ***run_broker()*** thread and the main function where the PyShark is capturing the packets. 
The first thread, chopping, is responsible for constantly switching wifi channels through 1, 6 and 11. The broker thread implements the producer-side of the broker where the messages are sent and are later consumed by the web app. 
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

As probe request packets are being captured by PyShark, they are processed by a function, ***packetHandler()***, which filters packets that only are sent by client devices searching for access points in broadcast. Therefore, all AP's sending beacon frames advertising their SSID as well as devices already connected to a certain SSID/access point are all dropped. After this process, the function retrieves the mac address from the packet and records the current time. This pair of values are saved this in a dictionary and represent the current list of in range devices. Afterward, the same mac address is introduced into the unique devices set, in order to prevent repetitions of the same mac address. In the end of every iteration of this function, another function is called: ***peopleUpdate()*** which goes through the dictionary of the current devices and checks the difference between the current time and the time when each mac address was captured and if the difference is greater than 5 seconds that pair of value stored in the dictionary is removed. 

## Broker

The broker connects to the IP address and a port of the broker installed on the Jetson's post and publishes messages on 2 different topics: **"sniffing/current"** and **"sniffing/unique"**. The first topic is where the current number of devices is published every 5 seconds while the second topic contains the number of unique devices, sent every 60 seconds. 


