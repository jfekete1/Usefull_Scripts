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
   when ($_ eq "pod" || $_ eq "pods") {
       createDescription($_, "kubectl run --generator=run-pod/v1 nginx-pod --image=nginx:alpine -l nginxLabel=asdasd\n", "apiVersion: v1 \nkind: Pod \nmetadata:\n  name: nginx-pod\nspec:\n  containers:\n  - name: nginx-container\n    image: nginx:alpine\n" );
   }
   when ($_ eq "service") {
       createDescription($_, "kubectl expose pod redis --port=6379 --name redis-service", "apiVersion: v1\nkind: Service\nmetadata:\n  labels:\n    run: redis\n  name: redis-service\nspec:\n  ports:\n  - port: 6379\n    protocol: TCP\n    targetPort: 6379\n  selector:\n    run: redis\n  sessionAffinity: None\n  type: ClusterIP\n");
       sayColor('bold red', "You can expose multi Node multi Pod Deployments too:");
       say "kubectl expose deployment webapp --type=NodePort --port=8080 --name=webapp-service --dry-run -o yaml > webapp-service.yaml\nto generate a service definition file. Then edit the nodeport in it and thus create the service.";
       sayColor('bold red', "Example NodePort type service:");
       say "apiVersion: v1\nkind: Service\nmetadata:\n  creationTimestamp: null\n  labels:\n    name: webapp-red\n  name: webapp-service-red\nspec:\n  ports:\n  - port: 8080\n    protocol: TCP\n    targetPort: 8080\n    nodePort: 30083\n  selector:\n    name: webapp-red\n  type: NodePort";
       sayColor('yellow', "kubectl create service nodeport <myservicename>");
   }
   when ($_ eq "namespace"){
       sayColor('bold green', "Setting namespace preference:");
       say "kubectl config current-context \nkubectl config set-context <here comes the current context name> --namespace=<insert-namespace-name-here>";
       createDescription($_,"kubectl create namespace app-space","apiVersion: v1\nkind: Namespace\nmetadata:\n  name: app-space\n  selfLink: /api/v1/namespaces/app-space\nspec:\n  finalizers:\n  - kubernetes\nstatus:\n  phase: Active");
   }
   when ($_ eq "deployment"){
       createDescription($_, "kubectl run nginx --image=nginx", "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.7.9\n        ports:\n        - containerPort: 80");
   }
   when ($_ eq "replicaset"){
       createDescription($_, "kubectl create -f replicaset.yml", "apiVersion: apps/v1\nkind: ReplicaSet\nmetadata:\n  name: frontend\n  labels:\n    app: guestbook\n    tier: frontend\nspec:\n  # modify replicas according to your case\n  replicas: 3\n  selector:\n    matchLabels:\n      tier: frontend\n  template:\n    metadata:\n      labels:\n        tier: frontend\n    spec:\n      containers:\n      - name: php-redis\n        image: gcr.io/google_samples/gb-frontend:v3");
   }
   when ($_ eq "clusterrole") {
       createDescription($_, "kubectl create clusterrole", "apiVersion: rbac.authorization.k8s.io/v1\nkind: ClusterRole\nmetadata:\n  name: secret-reader\nrules:\n- apiGroups: [\"\"]\n  resources: [\"secrets\"]\n  verbs: [\"get\", \"watch\", \"list\"]");
   }
   when ($_ eq "clusterrolebinding"){
       createDescription($_, "kubectl create clusterrolebinding", "apiVersion: rbac.authorization.k8s.io/v1\nkind: ClusterRoleBinding\nmetadata:\n  name: read-secrets-global\nsubjects:\n- kind: Group\n  name: manager # Name is case sensitive\n  apiGroup: rbac.authorization.k8s.io\nroleRef:\n  kind: ClusterRole\n  name: secret-reader\n  apiGroup: rbac.authorization.k8s.io");
   }
   when ($_ eq "configmap"){
       createDescription($_, "kubectl create configmap", "apiVersion: v1\nkind: ConfigMap\nmetadata:\n  creationTimestamp: 2016-02-18T18:52:05Z\n  name: game-config\n  namespace: default\n  resourceVersion: \"516\"\n  uid: b4952dc3-d670-11e5-8cd0-68f728db1985\ndata:\n  game.properties: |\n    enemies=aliens\n    lives=3\n    enemies.cheat=true\n    enemies.cheat.level=noGoodRotten\n    secret.code.passphrase=UUDDLRLRBABAS\n    secret.code.allowed=true\n    secret.code.lives=30\n  ui.properties: |\n    color.good=purple\n    color.bad=yellow\n    allow.textmode=true\n    how.nice.to.look=fairlyNice");
   }
   when ($_ eq "job"){
       createDescription($_, "kubectl create job", "apiVersion: batch/v1\nkind: Job\nmetadata:\n  name: pi\nspec:\n  template:\n    spec:\n      containers:\n      - name: pi\n        image: perl\n        command: [\"perl\",  \"-Mbignum=bpi\", \"-wle\", \"print bpi(2000)\"]\n      restartPolicy: Never\n  backoffLimit: 4");
   }
   when ($_ eq "poddisruptionbudget"){
       createDescription($_, "kubectl create poddisruptionbudget", "");
   }
   when ($_ eq "priorityclass"){
       createDescription($_, "kubectl create priorityclass", "apiVersion: scheduling.k8s.io/v1\nkind: PriorityClass\nmetadata:\n  name: high-priority\nvalue: 1000000\nglobalDefault: false\ndescription: asdasd");
   }
   when ($_ eq "quota"){
       createDescription($_, "kubectl create quota", "apiVersion: v1\nkind: ResourceQuota\nmetadata:\n  name: compute-resources\nspec:\n  hard:\n    requests.cpu: \"1\"\n    requests.memory: 1Gi\n    limits.cpu: \"2\"\n    limits.memory: 2Gi\n    requests.nvidia.com/gpu: 4");
   }
   when ($_ eq "role"){
       createDescription($_, "kubectl create role", "apiVersion: rbac.authorization.k8s.io/v1\nkind: Role\nmetadata:\n  namespace: default\n  name: pod-reader\nrules:\n- apiGroups: [\"\"]\n  resources: [\"pods\"]\n  verbs: [\"get\", \"watch\", \"list\"]");
   }
   when ($_ eq "rolebinding"){
       createDescription($_, "kubectl create rolebinding", "apiVersion: rbac.authorization.k8s.io/v1\nkind: RoleBinding\nmetadata:\n  name: read-pods\n  namespace: default\nsubjects:\n- kind: User\n  name: jane # Name is case sensitive\n  apiGroup: rbac.authorization.k8s.io\nroleRef:\n  kind: Role #this must be Role or ClusterRole\n  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to\n  apiGroup: rbac.authorization.k8s.io");
   }
   when ($_ eq "secret"){
       sayColor('bold red', "Encode text before creating secret:");
       say "echo -n \'textToEncode\' | base64";
       say "echo -n \'YWRtaW4=\' | base64 --decode";
       createDescription($_, "kubectl create secret", "apiVersion: v1\nkind: Secret\nmetadata:\n  name: mysecret\ntype: Opaque\ndata:\n  username: YWRtaW4=\n  password: MWYyZDFlMmU2N2Rm");
   }
   when ($_ eq "serviceaccount"){
       createDescription($_, "kubectl create serviceaccount", "apiVersion: v1\nkind: ServiceAccount\nmetadata:\n  creationTimestamp: 2015-08-07T22:02:39Z\n  name: default\n  namespace: default\n  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6\nsecrets:\n- name: default-token-uudge\nimagePullSecrets:\n- name: myregistrykey");
   }
   when ($_ eq "networkpolicy"){
       createDescription($_, "kubectl create -f tmp.yml", "apiVersion: networking.k8s.io/v1\nkind: NetworkPolicy\nmetadata:\n  name: test-network-policy\n  namespace: default\nspec:\n  podSelector:\n    matchLabels:\n      role: db\n  policyTypes:\n  - Ingress\n  - Egress\n  ingress:\n  - from:\n    - ipBlock:\n        cidr: 172.17.0.0/16\n        except:\n        - 172.17.1.0/24\n    - namespaceSelector:\n        matchLabels:\n          project: myproject\n    - podSelector:\n        matchLabels:\n          role: frontend\n    ports:\n    - protocol: TCP\n      port: 6379\n  egress:\n  - to:\n    - ipBlock:\n        cidr: 10.0.0.0/24\n    ports:\n    - protocol: TCP\n      port: 5978");
   }
   default {
       sayColor('bold red', "No information on object $_ !!");
       print "Use the command: ";
       sayColor('bold green', "kubectl api-resources ");
       say "To list all the possible resource types, and copy the NAME of the resource you want information on, to create that resource type."
   }
}
