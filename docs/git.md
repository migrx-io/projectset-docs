# Overview

**Git** Store ProjectSet and ProjectSetTemplate for one or more clusters.
Depending on needs and requirements, clusters or groups of clusters might be hosted by one or more Git repositories.

## Directory structure 

Example

```
├── README.md
├── projectsets.yaml
├── common-templates
├── prod-ocp
│   ├── crds
│   └── templates
└── test-ocp
    ├── crds
    └── templates
```

- **README.md**. Optional file that describes clusters within a repository.

- **projectsets.yaml**. Metadata file that describes the structure and hierarchy of directories for ProjectSet and ProjectSetTemplate for each cluster.

    Example

        envs:
          test-ocp-cluster:
            projectset-templates: test-ocp/templates  # path to ProjectSetTemplate dir for test-ocp-cluster
            projectset-crds: test-ocp/crds            # path to ProjectSet dir for test-ocp-cluster
          prod-ocp-cluster:
            projectset-templates: common-templates    # path to ProjectSetTemplate dir for prod-ocp-cluster
            projectset-crds: prod-ocp/crds            # path to ProjectSet dir for prod-ocp-cluster

- **projectset-templates and projectset-crds**. Each cluster should have its own directory for instance and templates CR files. The templates directory might be shared between multiple clusters if needed. Directories should reflect the state defined in the projectsets.yaml file.

    *Place .gitignore to each directory to save empty dir to git*



