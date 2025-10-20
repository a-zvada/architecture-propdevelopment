kubectl apply -f network-policies.yaml

kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 443
kubectl run back-end-app --image=nginx --labels role=back-end-api --expose --port 8443
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 443 
kubectl run admin-back-end-app --image=nginx --labels role=admin-back-end-api --expose --port 8443 