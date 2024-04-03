# Overview

**ProjectSet Operator** comes with three core resources: 

1. ProjectSetTemplate
2. ProjectSet
3. ProjectSetSync

### ProjectSetTemplate

You can define and share common rules and policies across instances. It can help you to manage and reuse them regarding your company's policy and governance. Instances that reference the same template inherit its rules but can be overridden in the instances themselves.

![Overview](./img/migrx_yaml.png)

Template includes k8s defininitions of resources:

- [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). Labels with be passed to created k8s resources 

- [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/). Annotations will be passed to created k8s resources

- [Resources Quota](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

- [Limit Range](https://kubernetes.io/docs/concepts/policy/limit-range/)

- [Roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

- [Role Binding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/). Maps IdP groups to Roles.

- [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

- [Secret](https://external-secrets.io/latest/introduction/overview/#externalsecret). Require [External Secret Operator](https://external-secrets.io/latest/)

- [Config Map](https://kubernetes.io/docs/concepts/configuration/configmap/)

- [Custom Resource Definition](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)


Example: 

```
apiVersion: project.migrx.io/v1alpha1
kind: ProjectSetTemplate
metadata:
  labels:
    app.kubernetes.io/name: projectsettemplate
    app.kubernetes.io/instance: dev-small
    app.kubernetes.io/part-of: projectset-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: projectset-operator
  name: dev-small
spec:

  labels:
    stage: dev
  annotations:
    app.kubernetes.io/template: dev-small

  roles:
    developer:
      - apiGroups:
          - ""
          - apps
        resources:
          - configmaps
          - deployments
          - pods
          - pods/log
        verbs: ["*"]

    admin:
      - apiGroups:
          - ""
          - apps
          - autoscaling
          - batch
          - extensions
          - policy
          - rbac.authorization.k8s.io
          - networking.k8s.io
          - storage.k8s.io
          - metrics.k8s.io
        resources:
          - configmaps
          - daemonsets
          - deployments
          - events
          - endpoints
          - jobs
          - pods
          - pods/log
          - pods/exec
          - persistentvolumes
          - persistentvolumeclaims
          - secrets
          - serviceaccounts
          - services
          - statefulsets
        verbs: ["*"]

  roleBindings:
    admin:
      - kind: "Group"
        name: "developer"
      - kind: "Group"
        name: "admin"
    developer:
      - kind: "Group"
        name: "developer"

  resourceQuota:
    hard:
      requests.cpu: "2"
      requests.memory: 3Gi
      limits.cpu: "4"
      limits.memory: 6Gi

  limitRange:
    limits:
      - default:
          cpu: 500m
          memory: "50Mi"
        defaultRequest:
          cpu: 500m
          memory: "50Mi"
        max:
          cpu: "1"
          memory: "4Gi"
        min:
          cpu: 100m
          memory: "50Mi"
        type: Container

  networkPolicy:

    allow-dns:
      podSelector:
        matchLabels: {}
      policyTypes:
      - Egress
      egress:
      - to:
        - namespaceSelector:
            matchLabels:
              name: kube-system
        ports:
        - protocol: UDP
          port: 53

    deny-egress:
      podSelector:
        matchLabels: {}
      policyTypes:
        - Egress

    deny-ingress:
      podSelector:
        matchLabels: {}
      policyTypes:
        - Egress

```

### ProjectSet

To onboard Kubernetes resources on a cluster, you need to create a ProjectSet custom resource. If you have defined templates and reference them from the custom resource ProjectSet instance, it will inherit the template and create all nested resources based on template values. It's possible to override some or all template values in the instance.


Instance includes k8s defininitions of resources:

- [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). Labels will be passed to created Kubernetes resources. If templates are used, then instance values will be added to the template's ones.

- [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/). Annotations will be passed to created Kubernetes resources. If templates are used, then instance values will be added to the template's ones. 

- **template**. ProjectSetTemplate name

- [Resources Quota](https://kubernetes.io/docs/concepts/policy/resource-quotas/). If not specified, then template values will be used if defined.

- [Limit Range](https://kubernetes.io/docs/concepts/policy/limit-range/). If not specified, then template values will be used if defined.

- [Roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/). If not specified, then template values will be used if defined.

- [Role Binding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/). Maps IdP groups to Roles. If not specified, then template values will be used if defined.

- [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/). If not specified, then template values will be used if defined.

- [Secret](https://external-secrets.io/latest/introduction/overview/#externalsecret). Require [External Secret Operator](https://external-secrets.io/latest/). If not specified, then template values will be used if defined.

- [Config Map](https://kubernetes.io/docs/concepts/configuration/configmap/). If not specified, then template values will be used if defined.

- [Custom Resource Definition](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/). If not specified, then template values will be used if defined.


Example: 

```
apiVersion: project.migrx.io/v1alpha1
kind: ProjectSet
metadata:
  labels:
    app.kubernetes.io/name: projectset
    app.kubernetes.io/instance: projectset 
    app.kubernetes.io/part-of: projectset-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: projectset-operator
  name: dev-app
spec:
  namespace: dev-app
  labels:
    app: frontend
  annotations:
    app.kubernetes.io/name: dev-app 
  template: dev-small

```


### ProjectSetSync

ProjectSetSync defines the Git source for the cluster to sync ProjectSetTemplate and ProjectSet custom resources.

Instance includes attributes:

- **gitRepo**. Git source repository with ProjectSetTemplate and ProjectSet for the cluster.

- **envName**. Environment name for the cluster. One repository might contain multiple clusters/directories, so you should specify the particular cluster environment directory within the repository.

- **gitBranch**. Git branch to sync state and where pull requests are merged.

- **syncSecInterval**. Sync interval. The ProjectSet Operator will check for the latest changes within that interval.

- **confFile**. Conf file (projectsets.yaml) for the repository that describes the directory hierarchy structure for clusters/environments. It defines the directory path for each repository.


Example: 

```
apiVersion: project.migrx.io/v1alpha1
kind: ProjectSetSync
metadata:
  labels:
    app.kubernetes.io/name: projectsetsync
    app.kubernetes.io/instance: projectsetsync-instance
    app.kubernetes.io/part-of: projectset-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: projectset-operator
  name: projectsetsync-instance
spec:
  gitRepo: https://github.com/migrx-io/projectset-crds.git
  envName: test-ocp-cluster
  gitBranch: main
  syncSecInterval: 15
  confFile: projectsets.yaml

```


