kubectl create deployment mysql --image=mysql:5.7 --dry-run -o yaml > deployment-mysql.yml
kubectl create secret generic mysql-pass --from-literal=password=admin --dry-run -o yaml > secret-my.yml
kubectl expose deployment webapp-deployment --name=webapp-service --target-port=8080 --type=NodePort --port=8080 --dry-run=client -o yaml > svc-webapp.yml


#DEFINITION FILES:
https://raw.githubusercontent.com/jfekete1/Usefull_Scripts/master/Kubernetes/Definitions/pv-default.yaml

#USEFULL COMMANDS:
export RAW_DEF=https://raw.githubusercontent.com/jfekete1/Usefull_Scripts/master/Kubernetes/Definitions
curl $RAW_DEF/pv-default.yaml > pv.yml
kubectl explain deployment --recursive > tmp.yml

#USEFULL INFOS:
-Ingress is actually a routing framework for kubernetes (Like symfony router for laravel)
-A Headless service is actually like a DNS server that gives static DNS entries for pods 
