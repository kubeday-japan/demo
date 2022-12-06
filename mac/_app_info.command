here="$(dirname ${BASH_SOURCE[0]-$0})"
cd $here

printf 'APP RESOURCES:\n\n'
kubectl get all
export PNAME=`kubectl get pods -l app=kubeday-demo -o jsonpath='{.items[0].metadata.name}'`
printf '\n\nAPP POD INFO:\n\n'
kubectl describe pod ${PNAME}
