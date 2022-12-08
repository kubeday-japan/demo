# KubeDay Japan 2022 -  Secure and Debuggable: Debugging Slim, Scratch and Distroless Kubernetes Containers

Event schedule [link](https://kubedayjapan2022.sched.com/event/1C8kj/secure-and-debuggable-debugging-slim-scratch-and-distroless-kubernetes-containers-saiyam-pathak-civo-limited-kyle-quest-slim-ai)

[Slides](./Secure%20and%20Debuggable%20-%20Debugging%20slim,%20scratch%20and%20distroless%20Kubernetes%20containers.pdf)


## Overview

This repo contains the talk demos. Type `make` to get a list of the main demo commands to run. Take a look at the make file for additional commands to prepare the demo application.

* `app` - the node.js demo application
* `Dockerfile` - the main Dockerfile (for the `fat` and `slim` app images)
* `Dockerfile.multistage_distroless` - the distroless version of the application Dockerfile
* `manifest.yaml` - the kubernetes manifest for the `fat`/`slim`/`distroless` versions of the application
* `Makefile` - helper make targes for the main demo commands and examples
* `mac` - helper scripts for Mac OS
* `ecc` - go app to create privileged ephemeral containers


## Useful/Demo Makefile Targets/Command

* `run_app` - starts the application using the original `fat` / non-optimized application container image
* `run_slim_app` - starts the application using the optimized `slim` application container image
* `run_dless_app` - starts the application using the distroless application container image
* `stop_app` - stops the application started with `run_app`, `run_slim_app` or `run_dless_app`
* `exec_app_shell` - tries to `exec` into the target application container (will be successful if the app is started with `run_app` and it'll fail if the app was started with `run_slim_app` or `run_dless_app`)
* `app_info` - shows useful application pod/container info (including the ephemeral container info when it's available)
* `get_logs` - prints application pod logs
* `dbg_app_bbox` - creates an ephemeral container and starts a debug session for target app container with `busybox` (note that running this again after you disconnect from the debug container will not be successful because `kubectl debug` will try to create an ephemeral container with the same name and that'll fail; if you want to reconnect use `kubectl attach`)
* `dbg_app_kk` - same as above, but it will use the node.js KoolKit image (`lightruncom/koolkits:node`)
* `dbg_app_nix` - same as above, but it will use a dynamically built `nixery` image (`nixery.dev/shell/which/lsof/ps/iproute2/netcat-gnu/tshark/tcpdump/strace/curl/jq/nodejs`)
* `dbg_app_nsh` - same as above, but it will use the `netshoot` (`nicolaka/netshoot`)
* `dbg_app_bbox_cp` - debug session using a pod copy with busybox
* `dbg_app_bbox_cp_del` - cleanup the pod copy created with `dbg_app_bbox_cp`
* `dbg_node_bbox` - debug node with `kubectl debug`
* `dbg_node_bbox_del` - cleanup the node debug session created with `dbg_node_bbox`
* `dbg_create_custom_kk` - create a custom privileged debug container using curl and [custom_kk_spec_with_priv.json](./custom_kk_spec_with_priv.json) as the request payload
* `dbg_attach_custom_kk` - attach to the privileged debug container with `dbg_create_custom_kk`


## Creating Custom Ephemeral Container (go app version)

Building the app (in `ecc`): `go build -o app`

Running the app: `./app -pod kubeday-demo-657564c8c9-5l4kj -container debug-custom-kk -target app -image lightruncom/koolkits:node`

Note that you'll need to replace the pod name (`kubeday-demo-657564c8c9-5l4kj`) with whatever you have in your current app deployment. You can use the same trick used Makefile to configure `$PNAME`, so you don't have to change the pod name all the time.

If you create the custom ephemeral container using the sample command above you'll be able to reuse `make dbg_attach_custom_kk` to attach to the created container.


## Debugging Container Images

1. `Netshoot` - https://github.com/nicolaka/netshoot (network trouble-shooting swiss-army container)

* Comprehensive toolset for diagnosis of network problems
* System level diagnosis tools

2. `KoolKits` (highly-opinionated, language-specific, batteries-included debug container images for Kubernetes by LightRun)

* `koolkit-jvm` - https://github.com/lightrun-platform/koolkits/blob/main/jvm/README.md
* `koolkit-node` - https://github.com/lightrun-platform/koolkits/tree/main/nodejs
* `koolkit-python` - https://github.com/lightrun-platform/koolkits/tree/main/python
* `koolkit-go` - https://github.com/lightrun-platform/koolkits/tree/main/golang

3. `nixery.dev` (build your own debugging container image on demand)

* Find packages to include here: https://search.nixos.org/packages


## Useful References

* [Ephemeral Containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers) - basic ephemeral container information from the Kubernetes docs
* [Debugging with an ephemeral debug container](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container) - basic `kubectl debug` examples from the Kubernetes docs
* [KEP-277: Ephemeral Containers](https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/277-ephemeral-containers) - useful design and use case information for `ephemeral containers` (covers existing and future functionality)
* [KEP-1441: kubectl debug](https://github.com/kubernetes/enhancements/tree/master/keps/sig-cli/1441-kubectl-debug) - useful design and use case information for `kubectl debug` (covers existing and future functionality)


