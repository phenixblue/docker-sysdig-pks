# docker-sysdig-pks
Docker Image for running Sysdig on PKS nodes


This was a quick and dirty hack to get the [kubectl-capture](https://github.com/sysdiglabs/kubectl-capture) plugin from Sysdig working for PKS nodes running the Ubuntu 16.04 Xenial stemcell. I'm unlikely to keep this up to date, but the general principal should remain the same if you need to improvise on veriosning and such.

USE AT YOUR OWN RISK!

## Build Image

This uses the existing [sysdig/sysdig](https://hub.docker.com/r/sysdig/sysdig) image, but manually loads the sysdig-probe kernel module for the specific kernel version of the underlying PKS node. 

### Identifying the appropriate package

    - As the kernel version is likely to change, you can try running the base `sysdig/sysdig` image and following the logs to see which sysdig-probe package it tries to install

        ```bash
        * Trying to load a system sysdig-probe, if present
        * Trying to find precompiled sysdig-probe for 4.15.0-42-generic
        Found kernel config at /host/boot/config-4.15.0-42-generic
        * Trying to download precompiled module from https://s3.amazonaws.com/download.draios.com/stable/sysdig-probe-binaries/sysdig-probe-0.25-x86_64-4.15.0-42-generic-9fd133f121fd0c8ec46afcaf61cc7e51.ko
        Download failed, consider compiling your own sysdig-probe and loading it or getting in touch with the sysdig community
        * Capturing system calls
        Unable to load the driver
        error opening device /host/dev/sysdig0. Make sure you have root credentials and that the sysdig-probe module is loaded.
        ```

### Download the appropriate sysdig-probe kernel module

    I found that you can basically ignore the last bits past `sysdig-probe-0.25-x86_64-4.15.0-42-generic`

        ```bash
        $ wget https://s3.amazonaws.com/download.draios.com/stable/sysdig-probe-binaries/sysdig-probe-0.25-x86_64-4.15.0-42-generic-751ae282dd3b11ba9ea4d659a9e2ffc8.ko

        --2019-04-20 05:26:53--  https://s3.amazonaws.com/download.draios.com/stable/sysdig-probe-binaries/sysdig-probe-0.25-x86_64-4.15.0-42-generic-751ae282dd3b11ba9ea4d659a9e2ffc8.ko
        Resolving s3.amazonaws.com (s3.amazonaws.com)... 52.216.170.213
        Connecting to s3.amazonaws.com (s3.amazonaws.com)|52.216.170.213|:443... connected.
        HTTP request sent, awaiting response... 200 OK
        Length: 674592 (659K) [binary/octet-stream]
        Saving to: ‘sysdig-probe-0.25-x86_64-4.15.0-42-generic-751ae282dd3b11ba9ea4d659a9e2ffc8.ko’
        ```

    - Edit the `Dockerfile` appropriately for the local copy of the kernel module

### Run Build

        ```bash
        $ docker build -t jmsearcy/sysdig-capture .

        Sending build context to Docker daemon  678.9kB
        Step 1/8 : FROM sysdig/sysdig
        ---> 8429858c7cb0
        Step 2/8 : LABEL maintainer joe@twr.io
        ---> Using cache
        ---> 7277a8548545
        Step 3/8 : ENV SYSDIG_HOST_ROOT /host
        ---> Using cache
        ---> 6fc195161501
        Step 4/8 : ENV HOME /root
        ---> Using cache
        ---> 26aa358edce2
        Step 5/8 : COPY sysdig-probe-0.24.2-x86_64-4.15.0-42-generic-751ae282dd3b11ba9ea4d659a9e2ffc8.ko /root/.sysdig
        ---> Using cache
        ---> 5536a36d9e5f
        Step 6/8 : COPY ./docker-entrypoint.sh /
        ---> e147b89fb7d5
        Step 7/8 : ENTRYPOINT ["/docker-entrypoint.sh"]
        ---> Running in 8cfaa2d472c0
        Removing intermediate container 8cfaa2d472c0
        apiVersion: v1
        ---> f93b5e7d37db
        Step 8/8 : CMD ["bash"]
        ---> Running in 9a5023a1bd2b
        Removing intermediate container 9a5023a1bd2b
        ---> b5edc6526be9
        Successfully built b5edc6526be9
        Successfully tagged jmsearcy/sysdig-capture:latest
        ```

### Push Image

        ```bash
        $ docker push jmsearcy/sysdig-capture

        The push refers to repository [docker.io/jmsearcy/sysdig-capture]
        d13b12c9bd83: Pushed
        777e8e34691e: Layer already exists
        ffd4285d34b6: Layer already exists
        eaed723544b6: Layer already exists
        b6f0e96aca8d: Layer already exists
        b47c0aa6928c: Layer already exists
        460a08061286: Layer already exists
        596d5f6f5802: Layer already exists
        08fc0a3fd18f: Layer already exists
        3e3a80f2657c: Layer already exists
        d172843784d6: Layer already exists
        1c1ee869b3e7: Layer already exists
        3e59f4745922: Layer already exists
        f6dabfe7c19d: Layer already exists
        ```

## Deploy with kubectl plugin

    - https://sysdig.com/blog/tracing-in-kubernetes-kubectl-capture-plugin/

    - Download [kubectl-capture](https://github.com/sysdiglabs/kubectl-capture) plugin

    - Edit plugin script to target the new image

    - Deploy to your hearts content!

        ```bash
        $ kubectl cap hello-kubernetes-2wrcl --namespace default -M 30 --snaplen 256

        Sysdig is starting to capture system calls:

        Node: worker-node1
        Pod: hello-kubernetes-2wrcl
        Duration: 30 seconds
        Parameters for Sysdig: -S -M 30 -pk -z -w /capture-hello-kubernetes-2wrcl-1555738502.scap.gz  --snaplen 256

        The capture has been downloaded to your hard disk at:
        /home/user1/sysdig-capture/capture-hello-kubernetes-2wrcl-1555738502.scap.gz
        ```

## Use Sysdig Inspect to vew capture files

    - https://github.com/draios/sysdig-inspect
    - https://sysdig.com/blog/sysdig-inspect
