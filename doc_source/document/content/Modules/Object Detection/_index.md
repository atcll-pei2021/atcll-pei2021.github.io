## Context

This module allows the detection of three diferent types of objects (people, vehicles and two wheeler vehicles) using a SDK called DeepStream running on a service in a Jetson Nano.


## Main functions
The main functions of the program are:
 - tiler_src_pad_buffer_probe(pad,info,u_data) - tiler_sink_pad_buffer_probe  will extract metadata received on OSD sink pad and update params for drawing rectangle, object information etc.
 - create_source_bin(index,uri) - Create a source GstBin to abstract this bin's content from the rest of the pipeline
 - cb_newpad(decodebin, decoder_src_pad,data) - Gets the source bin ghost pad and checks if the pad created by the decodebin is for video and not audio
 - main() - Creates a Pipeline element that will form a connection of other elements, a nvstreammux instance to form batches from one or more sources, a tiler and an egl sink

## Detection

```python
def tiler_src_pad_buffer_probe(pad,info,u_data):
    frame_number=0
    num_rects=0
    is_first_object=True
    gst_buffer = info.get_buffer()
    if not gst_buffer:
        print("Unable to get GstBuffer ")
        return

    # Retrieve batch metadata from the gst_buffer
    # Note that pyds.gst_buffer_get_nvds_batch_meta() expects the
    # C address of gst_buffer as input, which is obtained with hash(gst_buffer)
    batch_meta = pyds.gst_buffer_get_nvds_batch_meta(hash(gst_buffer))
    l_frame = batch_meta.frame_meta_list
    while l_frame is not None:
        try:
            # Note that l_frame.data needs a cast to pyds.NvDsFrameMeta
            # The casting is done by pyds.NvDsFrameMeta.cast()
            # The casting also keeps ownership of the underlying memory
            # in the C code, so the Python garbage collector will leave
            # it alone.
            frame_meta = pyds.NvDsFrameMeta.cast(l_frame.data)
        except StopIteration:
            continue
        
        is_first_object = True
        frame_number=frame_meta.frame_num
        l_obj=frame_meta.obj_meta_list
        num_rects = frame_meta.num_obj_meta
        obj_counter = {
        PGIE_CLASS_ID_VEHICLE:0,
        PGIE_CLASS_ID_PERSON:0,
        PGIE_CLASS_ID_BICYCLE:0,
        PGIE_CLASS_ID_ROADSIGN:0
        }

        while l_obj is not None:
            try:
                # Casting l_obj.data to pyds.NvDsObjectMeta
                obj_meta=pyds.NvDsObjectMeta.cast(l_obj.data)
            except StopIteration:
                continue
            obj_counter[obj_meta.class_id] += 1
            # Ideally NVDS_EVENT_MSG_META should be attached to buffer by the
            # component implementing detection / recognition logic.
            # Here it demonstrates how to use / attach that meta data.
            if(is_first_object):
                # Allocating an NvDsEventMsgMeta instance and getting reference
                # to it. The underlying memory is not manged by Python so that
                # downstream plugins can access it. Otherwise the garbage collector
                # will free it when this probe exits.
                msg_meta=pyds.alloc_nvds_event_msg_meta()
                msg_meta.bbox.top =  obj_meta.rect_params.top #Holds top coordinate of the box in pixels
                msg_meta.bbox.left =  obj_meta.rect_params.left #Holds left coordinate of the box in pixels
                msg_meta.bbox.width = obj_meta.rect_params.width #Holds width of the box in pixels.
                msg_meta.bbox.height = obj_meta.rect_params.height #Holds height of the box in pixels
                if msg_meta.bbox.left < 300: #retira area da Rua da Pega
                    obj_counter[obj_meta.class_id] -= 1
                is_first_object = True

            try:
                l_obj=l_obj.next
            
            except StopIteration:
                break
        
        global num_people
        global num_vehicles
        global num_twowheelers

        num_people = obj_counter[PGIE_CLASS_ID_PERSON]
        num_vehicles = obj_counter[PGIE_CLASS_ID_VEHICLE]
        num_twowheelers = obj_counter[PGIE_CLASS_ID_BICYCLE]

        # Get frame rate through this probe
        fps_streams["stream{0}".format(frame_meta.pad_index)].get_fps()
        try:
            l_frame=l_frame.next
        except StopIteration:
            break

    return Gst.PadProbeReturn.OK
```

## Local Broker

There are 2 types of values: **unique values** and **current values**. 

The **current values** are captured every second after analysing 12.4 video frames. This means that every second a message with the number of detected people, vehicles and two wheeler vehicles is sent to the local broker. 

The **unique values** are sent in a time interval of 60 seconds and they are the sum of every new object that appeared during that time interval in each category. That means that if during a minute 22 new people apear on the video feed, the people unique value at the end of that minute will be 22.

This captured data is sent to a local broker in 6 different topics:

```python

#current
currentppl_topic = "detection/people/current"
currentvehicles_topic = "detection/vehicle/current"
currenttwowheelers_topic = "detection/twowheelers/current"

#unique
uniqueppl_topic = "detection/people/unique"
uniquevehicles_topic = "detection/vehicle/unique"
uniquetwowheelers_topic = "detection/twowheelers/unique"
```

Since the data has to be sent in different time intervals, its handling has to be separate. To prevent sending several messages with the value 0 for hours (like for example during the night) to the broker, the code was changed in order to supress sending repeated zeros. To do this, every time a message is sent, it has to be checked if the previous message was a 0 and if the current message is also a 0.

```python
count = 0
    while True:
        if count == 60:
            previous_unique_p = num_people_unique
            previous_unique_v = num_vehicles_unique
            previous_unique_t = num_twowheelers_unique

            if not previous_unique_p == 0 or num_people_unique != 0:
                unpeople = json.dumps({"value" : num_people_unique, "TimeStamp" : time.time()})
                client.publish(uniqueppl_topic, unpeople)

            if not previous_unique_v == 0 or num_vehicles_unique != 0:
                unvehicles = json.dumps({"value" : num_vehicles_unique, "TimeStamp" : time.time()})
                client.publish(uniquevehicles_topic, unvehicles)

            if not previous_unique_t == 0 or num_twowheelers_unique != 0:
                untwowheelers = json.dumps({"value" : num_twowheelers_unique, "TimeStamp" : time.time()})
                client.publish(uniquetwowheelers_topic, untwowheelers)

            num_people_unique = 0
            num_vehicles_unique = 0
            num_twowheelers_unique = 0
            count = 0

        time.sleep(1)  #manda os valores de 1 em 1 segundo

        dif = (num_people - bk_numbers[0], num_vehicles - bk_numbers[1], num_twowheelers - bk_numbers[2])
        if dif[0] > 0:
            num_people_unique += dif[0]
        if dif[1] > 0:
            num_vehicles_unique += dif[1]
        if dif[2] > 0:
            num_twowheelers_unique += dif[2]
        count += 1

        if not previous_current_p == 0 or num_people != 0:
            crpeople = json.dumps({"value" : num_people, "TimeStamp" : time.time()})
            client.publish(currentppl_topic, crpeople)
            previous_current_p = num_people

        if not previous_current_v == 0 or num_vehicles != 0:
            crvehicles = json.dumps({"value" : num_vehicles, "TimeStamp" : time.time()})
            client.publish(currentvehicles_topic, crvehicles)
            previous_current_v = num_vehicles

        if not previous_current_t == 0 or num_twowheelers != 0:
            crtwowheelers = json.dumps({"value" : num_twowheelers, "TimeStamp" : time.time()})
            client.publish(currenttwowheelers_topic, crtwowheelers)
            previous_current_t = num_twowheelers
        bk_numbers = (num_people, num_vehicles, num_twowheelers)
```

#### Connection to Central Broker

All of the messages sent in topics to the local brokers are then sent to the central broker in IT to be accessed in the web application.

## Running the program

To run the program in the Jetson Nano:
```
python3 detector2.py rtsp://admin:admin@192.168.115.9/11
```

To continue running after closing the ssh session:
```
 nohup python3 -u detector2.py rtsp://admin:admin@192.168.115.9/11 </dev/null >/dev/null 2>&1 &
```

#### References



[Guide on how to install DeepStream SDK on the Jetson Nano](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_Quickstart.html)
