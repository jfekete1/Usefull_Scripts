#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
no warnings 'experimental';
use Term::ANSIColor;

my $object = "";
if ($ARGV[0]){ $object = $ARGV[0];}

sub createDescription {
    print color('bold blue');
    say "Imperative $_[0] example:";
    print color('reset');
    say $_[1];
    print color('bold yellow');
    say "Declarative $_[0] example:";
    print color('reset');
    say $_[2];
}
sub sayColor {
    print color($_[0]);
    say "$_[1]";
    print color('reset');
}

given ($object) {
   when ($_ eq "pod" || $_ eq "pods" || $_ eq "po") {
       createDescription($_, "kubectl run --generator=run-pod/v1 nginx-pod --image=nginx:alpine -l nginxLabel=asdasd\n", "apiVersion: v1 \nkind: Pod \nmetadata:\n  name: nginx-pod\nspec:\n  containers:\n  - name: nginx-container\n    image: nginx:alpine\n" );
   }
   when ($_ eq "service" || $_ eq "services" || $_ eq "svc") {
       createDescription($_, "kubectl expose pod redis --port=6379 --name redis-service", "apiVersion: v1\nkind: Service\nmetadata:\n  labels:\n    run: redis\n  name: redis-service\nspec:\n  ports:\n  - port: 6379\n    protocol: TCP\n    targetPort: 6379\n  selector:\n    run: redis\n  sessionAffinity: None\n  type: ClusterIP\n");
       sayColor('bold red', "You can expose multi Node multi Pod Deployments too:");
       say "kubectl expose deployment webapp --type=NodePort --port=8080 --name=webapp-service --dry-run -o yaml > webapp-service.yaml\nto generate a service definition file. Then edit the nodeport in it and thus create the service.";
       sayColor('bold red', "Example NodePort type service:");
       say "apiVersion: v1\nkind: Service\nmetadata:\n  creationTimestamp: null\n  labels:\n    name: webapp-red\n  name: webapp-service-red\nspec:\n  ports:\n  - port: 8080\n    protocol: TCP\n    targetPort: 8080\n    nodePort: 30083\n  selector:\n    name: webapp-red\n  type: NodePort";
       sayColor('yellow', "kubectl create service nodeport <myservicename>");
   }
   when ($_ eq "namespace" || $_ eq "namespaces" || $_ eq "ns"){
       sayColor('bold green', "Setting namespace preference:");
       say "kubectl config current-context \nkubectl config set-context <here comes the current context name> --namespace=<insert-namespace-name-here>";
       createDescription($_,"kubectl create namespace app-space","apiVersion: v1\nkind: Namespace\nmetadata:\n  name: app-space\n  selfLink: /api/v1/namespaces/app-space\nspec:\n  finalizers:\n  - kubernetes\nstatus:\n  phase: Active");
   }
   when ($_ eq "deployment" || $_ eq "deployments" || $_ eq "deploy"){
       createDescription($_, "kubectl run nginx --image=nginx", "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.7.9\n        ports:\n        - containerPort: 80");
   }
   when ($_ eq "replicaset" || $_ eq "replicasets" || $_ eq "rs"){
       createDescription($_, "kubectl create -f replicaset.yml", "apiVersion: apps/v1\nkind: ReplicaSet\nmetadata:\n  name: frontend\n  labels:\n    app: guestbook\n    tier: frontend\nspec:\n  # modify replicas according to your case\n  replicas: 3\n  selector:\n    matchLabels:\n      tier: frontend\n  template:\n    metadata:\n      labels:\n        tier: frontend\n    spec:\n      containers:\n      - name: php-redis\n        image: gcr.io/google_samples/gb-frontend:v3");
   }
   when ($_ eq "clusterrole" || $_ eq "clusterroles") {
       createDescription($_, "kubectl create clusterrole <cluster-role-name>", "apiVersion: rbac.authorization.k8s.io/v1\nkind: ClusterRole\nmetadata:\n  name: secret-reader\nrules:\n- apiGroups: [\"\"]\n  resources: [\"secrets\"]\n  verbs: [\"get\", \"watch\", \"list\"]");
   }
   when ($_ eq "clusterrolebinding" || $_ eq "clusterrolebindings"){
       createDescription($_, "kubectl create clusterrolebinding <cluster-role-binding-name>", "apiVersion: rbac.authorization.k8s.io/v1\nkind: ClusterRoleBinding\nmetadata:\n  name: read-secrets-global\nsubjects:\n- kind: Group\n  name: manager # Name is case sensitive\n  apiGroup: rbac.authorization.k8s.io\nroleRef:\n  kind: ClusterRole\n  name: secret-reader\n  apiGroup: rbac.authorization.k8s.io");
   }
   when ($_ eq "configmap" || $_ eq "configmaps" || $_ eq "cm"){
       createDescription($_, "kubectl create configmap <configmap-name>", "apiVersion: v1\nkind: ConfigMap\nmetadata:\n  creationTimestamp: 2016-02-18T18:52:05Z\n  name: game-config\n  namespace: default\n  resourceVersion: \"516\"\n  uid: b4952dc3-d670-11e5-8cd0-68f728db1985\ndata:\n  game.properties: |\n    enemies=aliens\n    lives=3\n    enemies.cheat=true\n    enemies.cheat.level=noGoodRotten\n    secret.code.passphrase=UUDDLRLRBABAS\n    secret.code.allowed=true\n    secret.code.lives=30\n  ui.properties: |\n    color.good=purple\n    color.bad=yellow\n    allow.textmode=true\n    how.nice.to.look=fairlyNice");
   }
   when ($_ eq "job" || $_ eq "jobs"){
       createDescription($_, "kubectl create job <job-name>", "apiVersion: batch/v1\nkind: Job\nmetadata:\n  name: pi\nspec:\n  template:\n    spec:\n      containers:\n      - name: pi\n        image: perl\n        command: [\"perl\",  \"-Mbignum=bpi\", \"-wle\", \"print bpi(2000)\"]\n      restartPolicy: Never\n  backoffLimit: 4");
   }
   when ($_ eq "poddisruptionbudget" || $_ eq "poddisruptionbudgets" || $_ eq "pdb"){
       createDescription($_, "kubectl create poddisruptionbudget NAME --selector=nginx --min-available=0", "apiVersion: policy/v1beta1\nkind: PodDisruptionBudget\nmetadata:\n  creationTimestamp: 2019-12-18T09:55:09Z\n  generation: 1\n  name: NAME\n  namespace: myproject\n  resourceVersion: \"705557\"\n  selfLink: /apis/policy/v1beta1/namespaces/myproject/poddisruptionbudgets/NAME\n  uid: 79d9a04e-217c-11ea-b368-5226a92a570c\nspec:\n  minAvailable: 0\n  selector:\n    matchExpressions:\n    - key: nginx\n      operator: Exists\nstatus:\n  currentHealthy: 0\n  desiredHealthy: 0\n  disruptedPods: null\n  disruptionsAllowed: 0\n  expectedPods: 0\n  observedGeneration: 1");
   }
   when ($_ eq "priorityclass" || $_ eq "priorityclasses" || $_ eq "pc"){
       createDescription($_, "kubectl create priorityclass <priorityclass-name>", "apiVersion: scheduling.k8s.io/v1\nkind: PriorityClass\nmetadata:\n  name: high-priority\nvalue: 1000000\nglobalDefault: false\ndescription: asdasd");
   }
   when ($_ eq "quota" || $_ eq "resourcequotas"){
       createDescription($_, "kubectl create quota <quota-name>", "apiVersion: v1\nkind: ResourceQuota\nmetadata:\n  name: compute-resources\nspec:\n  hard:\n    requests.cpu: \"1\"\n    requests.memory: 1Gi\n    limits.cpu: \"2\"\n    limits.memory: 2Gi\n    requests.nvidia.com/gpu: 4");
   }
   when ($_ eq "role" || $_ eq "roles"){
       createDescription($_, "kubectl create role <role-name>", "apiVersion: rbac.authorization.k8s.io/v1\nkind: Role\nmetadata:\n  namespace: default\n  name: pod-reader\nrules:\n- apiGroups: [\"\"]\n  resources: [\"pods\"]\n  verbs: [\"get\", \"watch\", \"list\"]");
   }
   when ($_ eq "rolebinding" || $_ eq "rolebindings"){
       createDescription($_, "kubectl create rolebinding <role-binding-name>", "apiVersion: rbac.authorization.k8s.io/v1\nkind: RoleBinding\nmetadata:\n  name: read-pods\n  namespace: default\nsubjects:\n- kind: User\n  name: jane # Name is case sensitive\n  apiGroup: rbac.authorization.k8s.io\nroleRef:\n  kind: Role #this must be Role or ClusterRole\n  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to\n  apiGroup: rbac.authorization.k8s.io");
   }
   when ($_ eq "secret" || $_ eq "secrets"){
       sayColor('bold red', "Encode text before creating secret:");
       say "echo -n \'textToEncode\' | base64";
       say "echo -n \'YWRtaW4=\' | base64 --decode";
       createDescription($_, "kubectl create secret mysecret", "apiVersion: v1\nkind: Secret\nmetadata:\n  name: mysecret\ntype: Opaque\ndata:\n  username: YWRtaW4=\n  password: MWYyZDFlMmU2N2Rm");
   }
   when ($_ eq "serviceaccount" || $_ eq "serviceaccounts" || $_ eq "sa"){
       createDescription($_, "kubectl create serviceaccount <service-account-name>", "apiVersion: v1\nkind: ServiceAccount\nmetadata:\n  creationTimestamp: 2015-08-07T22:02:39Z\n  name: default\n  namespace: default\n  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6\nsecrets:\n- name: default-token-uudge\nimagePullSecrets:\n- name: myregistrykey");
   }
   when ($_ eq "networkpolicy" || $_ eq "networkpolicies" || $_ eq "netpol"){
       createDescription($_, "No imperative command available for this resource type !! Just use: kubectl create -f tmp.yml", "apiVersion: networking.k8s.io/v1\nkind: NetworkPolicy\nmetadata:\n  name: test-network-policy\n  namespace: default\nspec:\n  podSelector:\n    matchLabels:\n      role: db\n  policyTypes:\n  - Ingress\n  - Egress\n  ingress:\n  - from:\n    - ipBlock:\n        cidr: 172.17.0.0/16\n        except:\n        - 172.17.1.0/24\n    - namespaceSelector:\n        matchLabels:\n          project: myproject\n    - podSelector:\n        matchLabels:\n          role: frontend\n    ports:\n    - protocol: TCP\n      port: 6379\n  egress:\n  - to:\n    - ipBlock:\n        cidr: 10.0.0.0/24\n    ports:\n    - protocol: TCP\n      port: 5978");
   }
   when ($_ eq "persistentvolume" || $_ eq "persistentvolumes" || $_ eq "pv"){
       createDescription($_, "No imperative command available for this resource type !!", "# Create PersistentVolume\n# You can put multiple definitions in one file. change the ip of NFS server\napiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: wordpress-persistent-storage\n  labels:\n    app: wordpress\n    tier: frontend\nspec:\n  capacity:\n    storage: 1Gi\n  accessModes:\n    - ReadWriteMany\n  nfs:\n    server: nfs01\n    # Exported path of your NFS server\n    path: \"/html\"\n\n---\napiVersion: v1\nkind: PersistentVolume\nmetadata:\n  name: mysql-persistent-storage\n  labels:\n    app: wordpress\n    tier: mysql\nspec:\n  capacity:\n    storage: 1Gi\n  accessModes:\n    - ReadWriteMany\n  nfs:\n    server: nfs01\n    # Exported path of your NFS server\n    path: \"/mysql\"");
   }
   when ($_ eq "persistentvolumeclaim" || $_ eq "persistentvolumeclaims" || $_ eq "pvc"){
       createDescription($_, "No imperative command available for this resource type !!", "apiVersion: v1\nkind: PersistentVolumeClaim\nmetadata:\n  name: mysql-persistent-storage\n  labels:\n    app: wordpress\nspec:\n  accessModes:\n    - ReadWriteMany\n  resources:\n    requests:\n      storage: 1Gi\n  volumeName: \"mysql-persistent-storage\"");
   }
   when ($_ eq "endpoint" || $_ eq "endpoints" || $_ eq "ep"){
       createDescription($_, "No imperative command available for this resource type !!", "");
   }
   when ($_ eq "taint" || $_ eq "taints"){
       createDescription($_, "kubectl taint node node01 \'app_type=alpha:NoSchedule\'", "");
       sayColor('bold green', "Check if the taint is applied: ");
       say "kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{\"\t\"}{.spec.taints}{\"\n\"}{end}'";
   }
   when ($_ eq "explain" || $_ eq "help"){
       say "kubectl explain ingress --recursive | less";
       say "kubectl explain ingress --recursive | grep -i rules -A10";
   }
   when ($_ eq "taint" || $_ eq "taints"){
       createDescription($_, "kubectl taint nodes node-name key=value:taint-effect", "");
   }
   when ($_ eq "toleration" || $_ eq "tolerations"){
       sayColor('bold yellow', "Create the pod first like: ");
       say "kubectl run alpha --generator=run-pod/v1 --image=redis --dry-run -o yaml > alpha-pod.yml";
       sayColor('bold yellow', "Then edit the pod: ");
       say "vi alpha-pod.yml \nspec:\n  tolerations:\n  - key: \"app_type\"\n    operator: \"Equal\"\n    value: \"alpha\"\n    effect: \"NoSchedule\"";
   }
   when ($_ eq "label" || $_ eq "labels" || $_ eq "nodelabel" || $_ eq "labelnode"){
       createDescription($_, "kubectl label nodes node02 app_type=beta", "check:\n  kubectl get nodes node02 --show-labels");
   }
   when ($_ eq "affinity" || $_ eq "setaffinity"){
       sayColor('bold yellow', "Set affinity on Deployment pods: ");
       say "kubectl run beta-apps --image=nginx --replicas=3 --dry-run -o yaml > beta.yml\nvi beta.yml";
       say "spec:\n  affinity:\n    nodeAffinity:\n      requiredDuringSchedulingIgnoredDuringExecution:\n        nodeSelectorTerms:\n        - matchExpressions:\n          - key: app_type\n            operator: In\n            values:\n            - beta";
   }
   when ($_ eq "ingress") {
       createDescription($_, "No imperative command available for this resource type !! \nkubectl explain ingress --recursive", "apiVersion: extensions/v1beta1\nkind: Ingress\nmetadata:\n  name: test-ingress\n  annotations:\n    nginx.ingress.kubernetes.io/rewrite-target: /\nspec:\n  rules:\n  - host: ckad-mock-exam-solution.com\nhttp:\n      paths:\n      - path: /video\n        backend:\n          serviceName: my-video-service\n          servicePort: 8080");
   }
   when ($_ eq "readinessprobe"){
       createDescription($_, "No imperative command available for this resource type !! \nkubectl explain pod --recursive | grep -i readiness -A10", "apiVersion: v1\nkind: Pod\nmetadata:\n  name: goproxy\n  labels:\n    app: goproxy\nspec:\n  containers:\n  - name: goproxy\n    image: k8s.gcr.io/goproxy:0.1\n    ports:\n    - containerPort: 8080\n    readinessProbe:\n      tcpSocket:\n        port: 8080\n      initialDelaySeconds: 5\n      periodSeconds: 10");
   }
   default {
       sayColor('bold red', "No information on object $_ !!");
       print "Use the command: ";
       sayColor('bold green', "kubectl api-resources ");
       say "To list all the possible resource types, and copy the NAME of the resource you want information on, to create that resource type.";
   }
}
