chmod 600 ~/.kube/config

az aks get-credentials --resource-group cafanwii-resource-group --name my-aks-cluster


added:
- gitlab-agent.tf

## We will implement flux moving forward
https://docs.gitlab.com/ee/user/clusters/agent/gitops/flux_tutorial.html

### create a new directory in gitlab
- create a new directory in gitlab: [flux-config]

### Create access token in Gitlab
Link: [https://gitlab.com/-/profile/personal_access_tokens](https://gitlab.com/-/profile/personal_access_tokens)

- named it: gitlab-for-flux            [pat-for-flux]
Scope: api

***Run in the terminal***

```
export GHUSER=<your-gitlab-username>
export GITLAB_TOKEN=glpat-MHYEvb1KUJoEXMVnV9bR
```

### FLUX Implementation
Link: [https://docs.gitlab.com/ee/user/clusters/agent/gitops/flux_tutorial.html](https://docs.gitlab.com/ee/user/clusters/agent/gitops/flux_tutorial.html)

- Install FluxCli

```
sudo curl -sL https://toolkit.fluxcd.io/install.sh | sudo bash
```

### Bootstrap flux:
Bootstrap flux:  [My bootstrap repo: ](https://gitlab.com/fluxgitopss/flux-config)

  - create a new group: [fluxgitopss]
  - create a new project in that group: [flux-config]
  - when flux bootsprays, it will create this directory structure:

    |- flux-config
       |- clusters
          |- my-aks-cluster
             |- flux-system
                |- gotk-components.yaml
                |- gotk-sync.yaml
                |- kustomization.yaml
                  
```
flux bootstrap gitlab \
--owner=fluxgitopss \
--repository=flux-config \
--branch=main \
--path=clusters/my-aks-cluster \
--deploy-token-auth
```

***It will create:*** clusters/my-aks-cluster/flux-system/

### check resources created:
```
kubectl get po -n flux-system
```

### Next Create a new project
- Next Create a new project under fluxgitopss called: [cafanwii-web-app-manifests]
   [The new project link: ](https://gitlab.com/fluxgitopss/cafanwii-web-app-manifests)

- create a yaml file in the project called: cafanwii-deployment.yaml. You can see the yaml in the bottom of this page.
- create deployment tokens in this project and store them safe. Select scopes:
  - settings --> repository --> deploy tokens [flux-repository-deploy-token]. Will give u name and token
    - username: gitlab+deploy-token-2413988
    - token: _XdFhMiZco_4U5pRHGhT

### Use flux-repository-deploy-token to create a secret

```
flux create secret git flux-deploy-authentication \
  --url=https://gitlab.com/fluxgitopss/cafanwii-web-app-manifests \
  --namespace=default \
  --username=gitlab+deploy-token-2413988 \
  --password=_XdFhMiZco_4U5pRHGhT
```

- Get secret yaml

```
kubectl -n default get secrets flux-deploy-authentication -o yaml
```

### Create 2 more files inside the [my-aks-cluster] directory. 
So this is how the tree structure will look:

    |- flux-config
       |- clusters
          |- my-aks-cluster
             |- cafanwii-web-app-manifests-source.yaml      # new file 1
             |- cafanwii-web-app-manifests-kustomize.yaml   # new file 2
             |- flux-system
                |- gotk-components.yaml
                |- gotk-sync.yaml
                |- kustomization.yaml

#### file 1: cafanwii-web-app-manifests-source.yaml

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: cafanwii-web-app-manifests
  namespace: default  # Namespace where Flux is installed
spec:
  interval: 10s  # Adjust the synchronization interval as needed
  url: https://gitlab.com/fluxgitopss/cafanwii-web-app-manifests.git  # remember this. Where I have my yaml manifests
  ref:
    branch: main
  secretRef:
    name: flux-deploy-authentication   # This is the name of the secret we saved from the deploy-token.
```

#### file 2: cafanwii-web-app-manifests-kustomize.yaml

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: cafanwii-web-app-kustomize
  namespace: default  # Namespace where Flux is installed
spec:
  interval: 1m  # Adjust the synchronization interval as needed
  path: ./  # Path to the directory containing your manifests within the Git repository
  prune: true  # Automatically remove resources that no longer exist in the Git repository
  sourceRef:
    kind: GitRepository
    name: cafanwii-web-app-manifests  # Reference to the GitRepository resource defined earlier
    namespace: default
  targetNamespace: default 
```


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```















##########################

## About the gitlab agent
- Register agentk
- see link: [https://docs.gitlab.com/ee/user/clusters/agent/install/index.html#create-an-agent-configuration-file](https://docs.gitlab.com/ee/user/clusters/agent/install/index.html#create-an-agent-configuration-file)


To register agentk:
    # .gitlab/agents/cafanwii-agent/config.yaml

- operator --> Kubernetes Clusters --> connect to cluster --> Register [save the credentials]

glagent-sk-u7JYwUbyrnLj9MXyAshf9-tvHoVcLp_v6LjbTv_FyoytVUg

```
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install cafanwii-agent gitlab/gitlab-agent \
    --namespace gitlab-agent-cafanwii-agent \
    --create-namespace \
    --set image.tag=v16.4.0-rc1 \
    --set config.token=glagent-sk-u7JYwUbyrnLj9MXyAshf9-tvHoVcLp_v6LjbTv_FyoytVUg \
    --set config.kasAddress=wss://kas.gitlab.com
```

