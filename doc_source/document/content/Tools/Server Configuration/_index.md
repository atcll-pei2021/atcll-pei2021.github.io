NVIDIA® DeepStream Software Development Kit (SDK) is an accelerated AI framework to build intelligent video analytics (IVA) pipelines.

The following section describes how to install DeepStream SDK on the **Jetson Nano**.
All steps are also available [here](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_Quickstart.html).

### Install Jetson SDK components

Download NVIDIA SDK Manager from https://developer.nvidia.com/embedded/jetpack. You will use this to install JetPack 4.5.1 GA (corresponding to L4T 32.5.1 release). This comes packaged with CUDA, TensorRT and cuDNN.

### Install Dependencies

Enter the following commands to install the prerequisite packages:

```
$ sudo apt install \
libssl1.0.0 \
libgstreamer1.0-0 \
gstreamer1.0-tools \
gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-ugly \
gstreamer1.0-libav \
libgstrtspserver-1.0-0 \
libjansson4=2.11-1
```

###### Install librdkafka (to enable Kafka protocol adaptor for message broker)

1. Clone the librdkafka repository from GitHub:
    ```
    $ git clone https://github.com/edenhill/librdkafka.git
    ```
2. Configure and build the library:
    ```
    $ cd librdkafka
    $ git reset --hard 7101c2310341ab3f4675fc565f64f0967e135a6a
    $ ./configure
    $ make
    $ sudo make install
    ```
3. Copy the generated libraries to the deepstream directory:
    ```
    $ sudo mkdir -p /opt/nvidia/deepstream/deepstream-5.1/lib
    $ sudo cp /usr/local/lib/librdkafka* /opt/nvidia/deepstream/deepstream-5.1/lib
    ```

### Install the DeepStream SDK

###### Method 1: Using SDK Manager

Select DeepStreamSDK from the ```Additional SDKs``` section along with JP 4.5.1 software components for installation.

###### Method 2: Using the DeepStream tar package **(method used by the group)**

1. Download the DeepStream 5.1 Jetson tar package ```deepstream_sdk_v5.1.0_jetson.tbz2```, to the Jetson device.

2. Enter the following commands to extract and install the DeepStream SDK:

    ```
    $  sudo tar -xvf deepstream_sdk_v5.1.0_jetson.tbz2 -C /
    $ cd /opt/nvidia/deepstream/deepstream-5.1
    $ sudo ./install.sh
    $ sudo ldconfig
    ```

###### Method 3: Using the DeepStream Debian package

Download the DeepStream 5.1 Jetson Debian package ```deepstream-5.1_5.1.0-1_arm64.deb```, to the Jetson device. Then enter the command:

```
$ sudo apt-get install ./deepstream-5.1_5.1.0-1_arm64.deb
```

>**Note:** If you install the DeepStream SDK Debian package using the dpkg command, you must install the following packages before installing the debian package:
libgstrtspserver-1.0-0
libgstreamer-plugins-base1.0-dev

###### Method 4:Using the apt-server

1. Open the apt source configuration file in a text editor, using a command similar to

    ```
    $ sudo vi /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
    ```

2. Change the repository name and download URL in the deb commands shown below:
    ```
    deb https://repo.download.nvidia.com/jetson/common r32.5 main
    ```

3. Save and close the source configuration file.

4.  Enter the commands:

    ```
    $ sudo apt update
    $ sudo apt install deepstream-5.1
    ```

###### Method 5: Use Docker container DeepStream [docker containers](https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_docker_containers.html) are available on NGC. See the Docker Containers section to learn about developing and deploying DeepStream using docker containers.

### Run deepstream-app (the reference application)

1. Navigate to the samples directory on the development kit.

2. Enter the following command to run the reference application:
    ```
    $ deepstream-app -c <path_to_config_file>
    ```
    Where ```<path_to_config_file>``` is the pathname of one of the reference application’s configuration files, found in ```configs/deepstream-app/```. See Package Contents for a list of the available files.


    >**Note:** 
    You can find sample configuration files under ```/opt/nvidia/deepstream/deepstream-5.1/samples``` directory. Enter this command to see application usage:
    ```$ deepstream-app --help```
    To save TensorRT Engine/Plan file, run the following command:
    ```$ sudo deepstream-app -c <path_to_config_file>```

3. To show labels in 2D Tiled display view, expand the source of interest with mouse left-click on the source. To return to the tiled display, right-click anywhere in the window.

4. Keyboard selection of source is also supported. On the console where application is running, press the z key followed by the desired row index (0 to 9), then the column index (0 to 9) to expand the source. To restore 2D Tiled display view, press ```z``` again.

###### Boost the clocks

After you have installed DeepStream SDK, run these commands on the Jetson device to boost the clocks:

```
$ sudo nvpmodel -m 0
$ sudo jetson_clocks
```

### Run precompiled sample applications

1. Navigate to the chosen application directory inside ```sources/apps/sample_apps```.

2. Follow the directory’s README file to run the application.

    >**Note:** 
    If the application encounters errors and cannot create Gst elements, remove the GStreamer cache, then try again. To remove the GStreamer cache, enter this command: ```$ rm ${HOME}/.cache/gstreamer-1.0/registry.aarch64.bin```
    When the application is run for a model which does not have an existing engine file, it may take up to a few minutes (depending on the platform and the model) for the file generation and the application launch. For later runs, these generated engine files can be reused for faster loading.
