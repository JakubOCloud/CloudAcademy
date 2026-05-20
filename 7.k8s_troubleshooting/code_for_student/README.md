# k8S troubleshoot task

## ISSUES :

After first apply without changing anything this is the message:
 `The Deployment "app-deployment" is invalid:` 
 ``* spec.template.metadata.labels: Invalid value: {"app":"my-apps"}: `selector` does not match template `labels` ``
 `* spec.template.spec.containers[0].volumeMounts[0].name: Not found: "data"`

### 01-pv.yaml and 02-pvc.yaml
- pv has only 1Gi of memory while pvc states that it have 2Gi
- pvc is looking to match labels with fast while pv has label with local
- difference in storageClassName
- PV has RWO while PVC wants RWM

### 04-deployment.yaml
- mismatch in template and selector labels
- replicas set to 0
- bad image there is no alpines
- bad configmap name should be app-configs
- mismatch in names for volumes and volume mounts
- bad pvc name should be app-pvc
- nginx is listening on port 80 not 8080

### 05-service.yaml
- bad app name in selector

## FIXES :

### 01-pv.yaml and 02-pvc.yaml
I changed only 02-pvc to match 01-pv: 
- Changed acces modes to RWO
- Changed size to 1Gi
- storageClassName to app-storage
- match labels to local

### 04-deployment.yaml
- set matchlabels to my-app
- replicas set to 3
- deleted s after alpine
- changed configmap name
- changed vollume name to data
- changed claimName
- changed port to 80

### 05-service.yaml
- Changed to my-app