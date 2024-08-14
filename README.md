# private-public-kubernetes-apps

This is a demo repository for the [Deploying public and private applications in Kubernetes](https://felipetrindade.com/public-private-apps/) blog post. All detailed information and explanations about this repository can be found in the blog post.

## Running the project
Make sure you have [Devbox](https://www.jetify.com/devbox) installed. This will manage all the dependencies of the project.

1) Install dependencies of the project

```sh
devbox shell
```

2) Export your Vultr credentials

```sh
export VULTR_API_KEY=BRYAAFNWHYEFY2ZHGTQSDZCHEA
```

3) Create the Kubernetes cluster

```sh
cd infrastructure
tofu init
tofu apply
```

This will create the Kubernetes cluster for you using Opentofu.

4) Create kube-config file

```sh
vultr-cli kubernetes config $(tofu output -raw cluster_id) | base64 -d >> ~/.kube/config
cd ..
```

5) Install Kubernetes Reflector

```sh
devbox run reflector
```

6) Create Vultr secrets and namespaces that will be used later

```sh
kubectl create namespace cert-manager
kubectl create namespace ingress-nginx
kubectl create secret generic vultr-credentials -n ingress-nginx --from-literal=apiKey=$VULTR_API_KEY
kubectl label secret vultr-credentials -n ingress-nginx created-manually=true
kubectl annotate secret vultr-credentials -n ingress-nginx reflector.v1.k8s.emberstack.com/reflection-auto-namespaces=kube-system,cert-manager
kubectl annotate secret vultr-credentials -n ingress-nginx reflector.v1.k8s.emberstack.com/reflection-allowed="true"
kubectl annotate secret vultr-credentials -n ingress-nginx reflector.v1.k8s.emberstack.com/reflection-auto-enabled="true"
```

7) Install NGINX Ingress

```sh
devbox run nginx-ingress
```

8) Install Cert Manager

```sh
devbox run cert-manager
```

It might take a while for the certificate to get healthy.

9) Install External-DNS

```sh
devbox run external-dns
```

It might take a while for records to be created and propagated by the DNS provider.

10) Deploy public application

```sh
devbox run public-app
```

Make sure you can access the public application using your browser.

11) Deploy private application

```sh
devbox run private-app
```

The private app will be accessible only within the Kubernetes network. You can test this by running:

```sh
kubectl run curl --image=nginx:alpine
kubectl exec -it curl -- curl https://private-app.demosfelipetrindade.top
```