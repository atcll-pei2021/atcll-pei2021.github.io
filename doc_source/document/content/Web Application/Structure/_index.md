## Basic architecture of the web application
The web application is a flask app, running on the gunicorn server and uses NGINX has a proxy server.

## File Structure
- \_\_init\_\_.py - initialization of the app
- main.py - main app running on server
- auth.py - management of the accounts: validation and intermediate on the access to the database
- /templates - folder containing all the Static rendered Jinja2 HTML files
  - /templates/template.html - contains the base HTML page for the dashboard
  - /templates/detection.html - extends _template_ and has the HTML code to show the detection of vehicles, devices, people and two-wheelers
  - /templates/moliceiros.html - extends _template_ and has the HTML code to show the detection data of moliceiros
  - /templates/base.html - contains the base HTML page for managing the accounts
  - /templates/login.html - extends _base_ and has the HTML code to login into the account
  - /templates/signup.html - extends _base_ and has the HTML code to create an account


## Main functions
The main functions of the app are:
 - main.detection() - renders the template of the main page where the detection data of vehicles, people, devices and two-wheelers is showed.
 - main.people() - renders the template of the page where the detection data of moliceiros is showed.
 - auth.login() - takes care of the account authentication and the page is rendered based on the success of it
 - auth.signup() - takes care of the creation of accounts and the page is rendered based on the success of it
 - auth.logout() - logouts the account and redirects to the main page, the detection dashboard

To render the HTML pages with **jinja** the functions return *render_template('person.html', pagename="Moliceiros and People detection")* the argument **pagename** renders the page name on the html files

## Broker access
In flask, we access the broker and subscribe to topics to get real-time data. On these lines of code we access the broker
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
    mqtt.subscribe('sniffing')  #where the topic is called 'sniffing'

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

## Server Sent Events (SSE)
To show in real time the broker data from flask to HTML, we need to open a socket using server sent events, for that in the app.py file app routes were created  for the server sent events, where is returned a Response of type **"text/event-stream"**

For the **html - template page**, on the DIVS regarding the cards and charts a connection to the respective SSE is made, and the values are showed in real-time. 

## Account's Database
In order to store and manage the user's accounts it was created an SQLite database called __user__.

Flask makes it more intuitive and practical with the integration of classes/libraries like: _SQLAlchemy_, _LoginManager_ and _UserMixin_.

- SQLAlchemy - library that facilitates the communication between the app and the database
- LoginManager - class used to hold the settings used for logging in
- UserMixin - class that provides default implementations for methods that flask_login expects user objects to have

The configuration is done in the **\_\_init\_\_.py** file:
```python
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin
# ...

# init SQLAlchemy
db = SQLAlchemy()

#define database
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True) # primary keys are required by SQLAlchemy
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(100))
    name = db.Column(db.String(1000))

def create_app():
  # ...
  app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite' #the path to the SQLite database file 
  app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # deactivate Flask-SQLAlchemy track modifications
  db.init_app(app) # Initialiaze sqlite database
  # The login manager contains the code that lets your application and Flask-Login work together
  login_manager = LoginManager() # Create a Login Manager instance
  login_manager.login_view = 'auth.login' # define the redirection path when login required and we attempt to access without being logged in
  login_manager.init_app(app) # configure it for login
  # ...

```
Then the database is created in the \_\_main\_\_ function in the __main.py__ file:
```python
if __name__ == "__main__":
  # ...
  db.create_all(app=create_app()) # create the SQLite database
```
## Babel Configuration
Flask-Babel is an extension to Flask that helps get text translations with the help of Jinja.

On the **createapp()** function in the **\_\_init\_\_.py** file:
```python
#Babel Configuration
app.config['BABEL_DEFAULT_LOCALE'] = 'en'  

#Creation of mqtt, socket and babel objects for the app
babel = Babel(app)

# set up babel
@babel.localeselector
def get_locale():
    if request.args.get('lang'):
        session['lang'] = request.args.get('lang')
    return session.get('lang', 'en')
```
To generate the translation files the following steps need to be made:

Run the pybabel command that comes with Babel to extract your strings:
```
pybabel extract -F babel.cfg -o messages.pot .
```

Generate the language translation file (ex.: pt)
```
pybabel init -i messages.pot -d translations -l pt
```
After translating the web application strings on the generated file (ex.: pt.po) compile
```
pybabel compile -d translations  
```
