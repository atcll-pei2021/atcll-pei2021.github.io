## Introduction

The goal of this API is to promote an easy access to all of the data that can be displayed in the dashboard. The data and our resources are accessed by URIs. The clients send requests to these URIs using the methods defined by the HTTP protocol to obtain data relative to that specific endpoint.

| Action | Method |                          Description                         |
|:------:|:------:|:------------------------------------------------------------:|
| Create |  ```POST```  |                  Create a new unique object                 |
|  Read  |   ```GET```  | Obtain information about a object or collection of objects |

## Endpoints



#### Sniffing Information
```GET``` /api/sniffing  
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/sniffing?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/sniffingunique
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/sniffingunique?start=1621300462000&end=1621372462000&bucket=hour&group=count


#### Detection Information

```GET``` /api/people
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/people?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/peopleunique
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/peopleunique?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/vehicle
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/vehicle?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/vehicleunique
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/vehicleunique?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/twowheeler
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/twowheeler?start=1621300462000&end=1621372462000&bucket=hour&group=count

```GET``` /api/twowheelerunique
- URL parameters
    ```start = [integer]```
    ```end = [integer]```
    ```bucket = day|hour|minute```
    ```group = count|avg|sum|min|max```

- Example call
https://dev.aveiro-open-lab.pt/api/twowheelerunique?start=1621300462000&end=1621372462000&bucket=hour&group=count

#### Sensors

These ends points return information related to the status of the services running on the different detection modules. This allows the application to know when the services stop running and to alert the administrator in case of such event.

```GET``` /api/sensors/p22_apu

- Example call
https://dev.aveiro-open-lab.pt/api/sensors/p22_apu

```GET``` /api/sensors/p1_apu

- Example call
https://dev.aveiro-open-lab.pt/api/sensors/p1_apu

```GET``` /api/sensors/pei_jetson

- Example call
https://dev.aveiro-open-lab.pt/api/sensors/pei_jetson


#### Camera controls

There are also endpoints that control the movement of a rotational camera. All of these endpoints follow the the call structure ```https://dev.aveiro-open-lab.pt/api/cam/<action>```.


```POST``` | ```GET``` /api/cam/up
```POST``` | ```GET``` /api/cam/down
```POST``` | ```GET``` /api/cam/left
```POST``` | ```GET``` /api/cam/right

```POST``` | ```GET``` /api/cam/upleft
```POST``` | ```GET``` /api/cam/upright
```POST``` | ```GET``` /api/cam/downright
```POST``` | ```GET``` /api/cam/downleft

```POST``` | ```GET``` /api/cam/zoomin
```POST``` | ```GET``` /api/cam/zoomout

```POST``` | ```GET``` /api/cam/focusin
```POST``` | ```GET``` /api/cam/focusout

```POST``` | ```GET``` /api/cam/irisin
```POST``` | ```GET``` /api/cam/irisout

```POST``` | ```GET``` /api/cam/auto
```POST``` | ```GET``` /api/cam/autostop


#### Authentication

There are reserved endpoints that allow the authentication of users and thus control the access to certain resources. 

```POST``` /login
- Example call
https://dev.aveiro-open-lab.pt/login

```POST``` /signup
- Example call
https://dev.aveiro-open-lab.pt/signup

```POST``` /logout
- Example call
https://dev.aveiro-open-lab.pt/logout

<!-- ## Access to the Instituto de Telecomunicações API -->







