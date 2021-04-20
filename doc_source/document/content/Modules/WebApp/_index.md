## Basic architecture of the web application
The web application is a flask app, running on the gunicorn server and uses NGINX has a proxy server.

## File Structure
- app.py - main app running on server
- /templates - folder containing all the Static rendered Jinja2 HTML files
- /templates/template.html - contains the base HTML page
- /templates/index.html - extends template and has the HTML code to homepage elements
- /templates/person.html - extends template and has the HTML code to show the detection data

## Main functions
The two main functions of the app are **home()** and **people()**:
 - home() - renders the template of the index HTML webpage.
 - people() - renders the template of the main page where the detection data is showed.

To render the HTML pages with **jinja** the functions return *render_template('person.html', pagename="Moliceiros and People detection")* the argument **pagename** renders the page name on the html files

## Broker access
In flask we access the broker and subscribe to topics to get real time data. On these lines of code we access the broker
```python
app.config['MQTT_BROKER_URL'] = '###.nap.av.it.pt'
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_REFRESH_TIME'] = 1.0
mqtt = Mqtt(app)
```

**mqtt = Mqtt(app)** starts the broker access for the Broker.
**handle_connect** subscribes to the topic, and **handle_mqtt_message**, gets the message in real-time and sends it through a socket to the web app
```python
@mqtt.on_connect()
def handle_connect(client, userdata, flags, rc):
    mqtt.subscribe('sniffing')

@mqtt.on_message()
def handle_mqtt_message(client, userdata, message):
    data = dict(
        topic=message.topic,
        payload=message.payload.decode()
    )
    # emit a mqtt_message event to the socket containing the message data
    socketio.emit('mqtt_message', data=data)
    print(data)
```

## Socket IO
To show in real time the broker data from flask to HTML, we need to open a socket using socket.io, for that in the app.py file we:
create a variable named **socketio = SocketIO(app)**, and when receiving a message from the broker we send the data to the socket **socketio.emit('mqtt_message', data=data)**

On the **html - template page**:

```html
  <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/socket.io/4.0.1/socket.io.min.js"></script>
  <script type="text/javascript" charset="utf-8">
    $(document).ready(function() {
      var socket = io();
      socket.on('connect', function() {
          socket.emit('my event', {data: 'I\'m connected!'});
      });

      // listen for mqtt_message events
      // when a new message is received, log and append the data to the page
      socket.on('mqtt_message', (data) => {
        console.log(data);
        $('#sniffing_div').html(data['payload']); //replace sniffing div
      })
    });
  </script>
```
We connect to the socket and then send the data to the corresponded div