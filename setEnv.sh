#source setEnv.sh
export RAW_DEF=https://raw.githubusercontent.com/jfekete1/Usefull_Scripts/master/Kubernetes/Definitions
export TMP_DEF=${1:-deployment}
export TMP_YML=/tmp/tmp.yml
curl $RAW_DEF/kubeStructureInfo.pl > k8help.pl
chmod 777 k8help.pl
kubectl explain $TMP_DEF --recursive > $TMP_YML
cp k8help.pl /usr/local/bin/k8help.pl
alias kcr="kubectl create -f"
alias secret="kubectl create secret generic mysql-pass --from-literal=password=admin --dry-run -o yaml > secret.yml"
alias deployment="kubectl create deployment mysql --image=mysql:5.7 --dry-run -o yaml > deployment.yml"
alias service_nodeport="while read line do kubectl expose deployment $line --name=webapp-service --target-port=8080 --type=NodePort --port=8080 --dry-run -o yaml > service-nodeport-webapp.yml done"
