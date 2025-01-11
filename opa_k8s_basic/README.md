```
# Step 1: Install Prerequisites

1. **Install Docker Desktop for Windows**  
   - Download and install Docker Desktop from [Docker's official site](https://www.docker.com/products/docker-desktop).
   - Enable Kubernetes during the installation:  
     - Go to **Settings > Kubernetes**.  
     - Check the box for **Enable Kubernetes** and apply the changes.
   - Once Kubernetes is enabled, verify the setup:
     ```bash
     kubectl version --client && kubectl cluster-info
     ```

2. **Install `kubectl`**  
   - Download the Kubernetes CLI (`kubectl`) from [Kubernetes releases](https://kubernetes.io/releases/).
   - Add it to your system's PATH and verify:
     ```bash
     kubectl version --client
     ```

3. **Install Helm (optional for easier Gatekeeper installation)**  
   - Download Helm from [Helm releases](https://helm.sh/docs/intro/install/).
   - Verify the installation:
     ```bash
     helm version
     ```

# Step 2: Set Up a Local Kubernetes Cluster

Verify Kubernetes is Running: After enabling Kubernetes in Docker Desktop, ensure the local cluster is up:

```
kubectl get nodes
```

You should see a node named something like docker-desktop.

## (Optional) Use Minikube (If Docker Desktop Isn't Preferred):

1. Install Minikube: 
   ```
   choco install minikube -y
   ```

2. Start Minikube: 
   ```
   minikube start --driver=docker
   ```

3. Verify Minikube is running: 
   ```
   minikube status
   ```

## Step 3: Install OPA Gatekeeper

### Install Using Helm
Add the Gatekeeper Helm chart and install it:

```
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update
helm install gatekeeper gatekeeper/gatekeeper --namespace gatekeeper-system --create-namespace
```

### Install Using YAML Manifests
If Helm is not an option, apply the Gatekeeper YAML manifests:

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.10/deploy/gatekeeper.yaml
```

### Verify Installation
Check that Gatekeeper is running:

```
kubectl get pods -n gatekeeper-system
```

You should see pods like `gatekeeper-controller-manager`.

# Step 4: Create and Test a Policy

## Create a Constraint Template: 
Save the following YAML as `constraint-template.yaml`:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8sreadonlyrootfilesystem
spec:
  crd:
    spec:
      names:
        kind: K8sReadOnlyRootFilesystem
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sreadonlyrootfilesystem

        violation[{"msg": msg}] {
            input.review.kind.kind == "Pod"
            container := input.review.object.spec.containers[_]
            not container.securityContext.readOnlyRootFilesystem
            msg := "Containers must set readOnlyRootFilesystem to true"
        }
```

## Apply the template:

```bash
kubectl apply -f constraint-template.yaml
```

## Create a Constraint: 
Save the following YAML as `constraint.yaml`:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sReadOnlyRootFilesystem
metadata:
  name: require-readonly-root-filesystem
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

## Apply the constraint:

```bash
kubectl apply -f constraint.yaml
```

## Test the Policy:

Create a non-compliant pod manifest (`test-pod.yaml`): 

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
```

Attempt to apply it: 

```bash
kubectl apply -f test-pod.yaml
```

The request should be denied with a message: 

> Error from server: admission webhook "validation.gatekeeper.sh" denied the request: Containers must set readOnlyRootFilesystem to true

```
