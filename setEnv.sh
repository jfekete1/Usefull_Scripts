#source setEnv.sh
export RAW_DEF=https://raw.githubusercontent.com/jfekete1/Usefull_Scripts/master/Kubernetes/Definitions
export TMP_DEF=${1:-deployment}
export TMP_YML=/tmp/tmp.yml
export YML_TMP=/tmp/tmp.yml
curl $RAW_DEF/kubeStructureInfo.pl > k8help.pl
chmod 777 k8help.pl
kubectl explain $TMP_DEF --recursive > $TMP_YML
cp k8help.pl /usr/local/bin/k8help.pl
alias kcr="kubectl create -f"
alias secret="kubectl create secret generic mysql-pass --from-literal=password=admin --dry-run -o yaml > secret.yml"
alias deployment="kubectl create deployment mysql --image=mysql:5.7 --dry-run -o yaml > deployment.yml"
cat > service_nodeport.sh <<EOF
#!/bin/bash

kubectl expose deployment \$1 --name=\$1 --target-port=8080 --type=NodePort --port=8080 --dry-run -o yaml > service-nodeport-\$1.yml
echo "Successfuly created service-nodeport-\$1.yml file !!"
EOF
chmod 777 service_nodeport.sh
cp service_nodeport.sh /usr/local/bin/service_nodeport
