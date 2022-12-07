# KubeDay Japan 2022 -  Secure and Debuggable: Debugging Slim, Scratch and Distroless Kubernetes Containers

This repo contains the talk demos. Type `make` to get a list of the main demo commands to run. Take a look at the make file for additional commands to prepare the demo application.

* `app` - the node.js demo application
* `Dockerfile` - the main Dockerfile (for the `fat` and `slim` app images)
* `Dockerfile.multistage_distroless` - the distroless version of the application Dockerfile
* `manifest.yaml` - the kubernetes manifest for the `fat`/`slim`/`distroless` versions of the application
* `Makefile` - helper make targes for the main demo commands and examples
* `mac` - helper scripts for Mac OS
* `ecc` - go app to create privileged ephemeral containers

## Creating Custom Ephemeral Container (go app)

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

