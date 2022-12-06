default: help
.PHONY: default

help:
	 @awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help

#####################

run_app: ## run fat app (k8s)
	sed -e 's|APP_VERSION|fat|g' manifest.yaml | kubectl apply -f -
.PHONY: run_app

run_slim_app: ## run slim app (k8s)
	sed -e 's|APP_VERSION|slim|g' manifest.yaml | kubectl apply -f -
.PHONY: run_slim_app

run_dless_app: ## run distroless app (k8s)
	sed -e 's|APP_VERSION|distroless|g' manifest.yaml | kubectl apply -f -
.PHONY: run_dless_app

stop_app: ## stop app (k8s)
	kubectl delete deployments,services -l app=kubeday-demo
.PHONY: stop_app

app_info: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
app_info: ## show app pod info (k8s)
	kubectl describe pod $(PNAME)
	kubectl get pod ${PNAME} -o jsonpath='{.spec.ephemeralContainers}' | jq
.PHONY: app_info

all_info: app_info
all_info: ## show all cluster info (k8s)
	kubectl get all
.PHONY: all_info

exec_app_shell: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
exec_app_shell: ## exec shell on app container (k8s)
	kubectl exec -it -c app $(PNAME) -- bash
.PHONY: exec_app_shell

get_logs: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
get_logs: ## exec shell on app container (k8s)
	kubectl logs $(PNAME)
.PHONY: get_logs

##

dbg_app_bbox: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_app_bbox: ## debug session for target app container with busybox (k8s)
	kubectl debug -it -c debug-sidecar-bbox --image busybox --target app ${PNAME}
.PHONY: dbg_app_bbox

dbg_app_kk: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_app_kk: ## debug session for target app container with koolkits (k8s)
	kubectl debug -it -c debug-sidecar-kk --image lightruncom/koolkits:node --target app ${PNAME}
.PHONY: dbg_app_kk

dbg_app_nix: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_app_nix: ## debug session for target app container with nixery (k8s)
	kubectl debug -it -c debug-sidecar-nix --image nixery.dev/shell/which/lsof/ps/iproute2/netcat-gnu/tshark/tcpdump/strace/curl/jq/nodejs --target app ${PNAME}
.PHONY: dbg_app_nix

dbg_app_nsh: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_app_nsh: ## debug session for target app container with netshoot (k8s)
	kubectl debug -it -c debug-sidecar-netshoot --image nicolaka/netshoot --target app ${PNAME}
.PHONY: dbg_app_nsh


# extra examples


dbg_app_bbox_cp: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_app_bbox_cp: ## debug session using a pod copy with busybox (k8s)
	kubectl debug -it -c debug-sidecar-bbox-copy --image busybox --copy-to debugged-pod-copy --share-processes ${PNAME}
.PHONY: dbg_app_bbox_copy

dbg_app_bbox_cp_del:
	kubectl delete pod debugged-pod-copy
.PHONY: dbg_app_bbox_cp_del

dbg_node_bbox: ## debug node with busybox (k8s)
	#note: the node name hardcoded for a local Rancher Desktop setup
	kubectl debug node/lima-rancher-desktop -it --image=busybox
.PHONY: dbg_node_bbox

dbg_node_bbox_del:
	kubectl get pods --no-headers=true | awk '/^node-debugger-/{print $1}' | xargs kubectl delete pod
.PHONY: dbg_node_bbox_del


# EC API examples

dbg_create_custom_kk: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_create_custom_kk: ## create a custom privileged debug container (k8s)
	kubectl proxy &
	curl -v -XPATCH -H "Content-Type: application/strategic-merge-patch+json" \
	"http://localhost:8001/api/v1/namespaces/default/pods/${PNAME}/ephemeralcontainers" --data-binary @$(CURDIR)/custom_kk_spec_with_priv.json
.PHONY: dbg_create_custom_kk

dbg_attach_custom_kk: export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
dbg_attach_custom_kk: ## attach to the existing privileged debug container (k8s)
	kubectl attach -it -c debug-custom-kk ${PNAME}
.PHONY: dbg_attach_custom_kk



#####################

# Standalone application helpers (no k8s)

srun_app:
	nerdctl -n k8s.io run -it --rm -p 8080:8080 --name app ghcr.io/kubeday-japan/demo-node-app:fat
.PHONY: srun_app

srun_slim_app:
	nerdctl -n k8s.io run -it --rm -p 8080:8080 --name app ghcr.io/kubeday-japan/demo-node-app:slim
.PHONY: srun_slim_app

sstop_app:
	nerdctl -n k8s.io stop app
.PHONY: sstop_app

#####################

ghcr_login:
	@echo $(GHCR_PAT) | nerdctl -n k8s.io login ghcr.io -u kubeday-japan --password-stdin
.PHONY: ghcr_login

build_app_image:
	nerdctl -n k8s.io build --tag kubeday/app:demo .
	nerdctl -n k8s.io tag  kubeday/app:demo ghcr.io/kubeday-japan/demo-node-app:fat
.PHONY: build_app_image

build_app_distroless_image:
	nerdctl -n k8s.io build --tag ghcr.io/kubeday-japan/demo-node-app:distroless -f ./Dockerfile.multistage_distroless .
.PHONY: build_app_distroless_image

publish_app_distroless_image: ghcr_login
	nerdctl -n k8s.io push ghcr.io/kubeday-japan/demo-node-app:distroless
.PHONY: publish_app_distroless_image

publish_app_image: ghcr_login
	nerdctl -n k8s.io push ghcr.io/kubeday-japan/demo-node-app:fat
.PHONY: publish_app_image

get_slim_app_image: #ghcr_login
	nerdctl -n k8s.io pull ghcr.io/kubeday-japan/demo-node-app:slim
.PHONY: get_slim_app_image







