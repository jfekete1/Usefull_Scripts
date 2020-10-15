#source setEnv.sh
export RAW_DEF=https://raw.githubusercontent.com/jfekete1/Usefull_Scripts/master/Kubernetes/Definitions
export TMP_DEF=${1:-deployment}
curl $RAW_DEF/kubeStructureInfo.pl > help.pl
chmod 777 help.pl
kubectl explain $TMP_DEF --recursive > tmp.yml
