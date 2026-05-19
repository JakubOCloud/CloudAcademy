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


## FIXES :

### 01-pv.yaml and 02-pvc.yaml
I changed only 02-pvc to match 01-pv: 
- Changed acces modes to RWO
- Changed size to 1Gi
- storageClassName to app-storage
- match labels to local