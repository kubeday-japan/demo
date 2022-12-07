package main

import (
    "context"
    "fmt"
    "flag"
    "os"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/apimachinery/pkg/api/errors"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func main() {
	var (
		nsTarget string
		podTarget string
		containerTarget string
		ecImage string
		ecName string
		kubeconfig string
	)

	flag.StringVar(&nsTarget, "ns", "default", "namespace to target")
	flag.StringVar(&podTarget, "pod", "", "pod to target")
	flag.StringVar(&containerTarget, "target", "", "container to target")
	flag.StringVar(&ecImage, "image", "busybox", "ephemeral container image")
	flag.StringVar(&ecName, "container", "debug-container", "ephemeral container name")
	flag.StringVar(&kubeconfig, "kubeconfig", "${HOME}/.kube/config", "k8s config to target")

	flag.Parse()

	if podTarget == "" {
		fmt.Println("no target pod info... exiting")
		return
	}

    if containerTarget == "" {
        fmt.Println("no target container info... exiting")
        return
    }

    api, err := apiClientFromConfig(kubeconfig)
    if err != nil {
    panic(fmt.Errorf("could not create client: %w", err))
    }
    ctx := context.Background()

    // Get the Pod
    pod, err := api.
        CoreV1().
        Pods(nsTarget).
        Get(ctx, podTarget, metav1.GetOptions{})
    
    if errors.IsNotFound(err) {
        fmt.Printf("Target pod not found (%s/%s)\n", nsTarget, podTarget)
    } else if statusError, isStatus := err.(*errors.StatusError); isStatus {
        fmt.Printf("Error getting target pod (%s/%s): %v\n",
            nsTarget, podTarget, statusError.ErrStatus.Message)
    } else if err != nil {
        panic(err)
    }
    
    fmt.Printf("Found target pod (%s/%s)\n", nsTarget, podTarget)

    ecInfo := newEphemeralContainerInfo(containerTarget, ecName, ecImage, nil, true)
    pod.Spec.EphemeralContainers = append(pod.Spec.EphemeralContainers, ecInfo)
    
    _, err = api.
        CoreV1().
        Pods(pod.Namespace).
        UpdateEphemeralContainers(ctx, pod.Name, pod, metav1.UpdateOptions{})

    if err != nil {
        panic(err)
    }
}

func newEphemeralContainerInfo(
    target string,    // target container in the pod
    name string,      // name to use for the ephemeral container (must be unique)
    image string,     // image to use for the ephemeral container
    command []string, // custom ENTRYPOINT to use for the ephemeral container (yes, it's not CMD :-))
    isPrivileged bool,// true if it should be a privileged container
    ) corev1.EphemeralContainer {
    isTrue := true
    out := corev1.EphemeralContainer{
        TargetContainerName: target,
        EphemeralContainerCommon: corev1.EphemeralContainerCommon{
            TTY:   true,
            Stdin: true,            
            Name:  name,
            Image: image,
            Command: command,
        },
    }

    if isPrivileged {
        out.EphemeralContainerCommon.SecurityContext = &corev1.SecurityContext{
            Privileged: &isTrue,
        }
    }

    return out
}

func apiClientFromConfig(kubeconfig string) (*kubernetes.Clientset, error) {
    kubeconfig = os.ExpandEnv(kubeconfig)

    config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
    if err != nil {
        return nil, err
    }
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        return nil, err
    }

    return clientset, nil
}
