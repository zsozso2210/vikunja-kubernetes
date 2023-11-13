# vikunja-kubernetes

## Overview
This documentation outlines the process of setting up a local Kubernetes cluster using Terraform and Kind (Kubernetes in Docker) with dedicated worker nodes. The deployment includes the installation of ArgoCD, a powerful GitOps continuous delivery tool, utilizing a Helm chart for streamlined management within the Kubernetes environment.

## Motivation
The motivation behind this deployment is to showcase a best-practice approach to setting up a Todo App in a Kubernetes environment.

## Infrastructure and Deployment Toolset
-  Cluster Setup via Terraform:
The foundation of this infrastructure is laid with Terraform, creating a local Kubernetes cluster (Kind) with provisioned worker nodes. This approach ensures a controlled and reproducible environment for testing and development.

- ArgoCD Deployment:
It is deployed onto the Kubernetes cluster through a Helm chart by Terraform. 
ArgoCD's GitOps approach allows for declarative and version-controlled application deployment.
- Helm is a Kubernetes package manager designed for simplifying application deployment and management. 
With Helm, users can easily define, deploy, and manage applications, version control, dependency management.

***
## High Availability Configurations:
The applications are configured for high availability using various Kubernetes features:

- Multiple Replicas:
Ensures redundancy and resilience in case of node failures or increased load.
Node Affinity:
- Assigns worker nodes based on specific labels, optimizing resource utilization. 
- TopologyKeys:
Distributes workloads among nodes based on defined topologies, enhancing fault tolerance.
- Affinity and AntiAffinity Rules:
Kubernetes Affinity and Anti-Affinity Rules enable precise control over the scheduling of applications by specifying node preferences or constraints, ensuring optimal placement and resource utilization within a cluster.

***
# Application Deployments:
ArgoCD takes charge of deploying essential applications onto the Kubernetes cluster:


### PostgreSQL Database (Helm):
Deployed using Helm for simplicity and consistency.
I made several adjustments to the default Bitnami's values to enhance high availability. 
I modified the "nodeAffinityPreset" and "podAntiAffinityPreset" along with "topologySpreadConstraints" to ensure optimal deployment across nodes. Additionally, I configured "resources" to prevent pod eviction, and I utilized the "initdbScripts" to create distinct databases for Keycloak and the Vikunja app during Helm chart deployments. 

### External Secret Operator (Helm):
I have choosed External Secret Operator with Google Secret Manager to enhance the security and manageability of sensitive information within the Kubernetes environment.
This allows to store secrets in a GIT and then access them from applications in a secure and controlled way.
The operator synchronizes secrets from configured Google Secret manager with minimal privileged role (Secret Manager Secret Accessor)
https://cloud.google.com/secret-manager/docs/manage-access-to-secrets 

### Kube Prometheus Stack (Helm)
I selected the Kube Prometheus Stack for monitoring 
The Kube Prometheus Stack combines Prometheus, Grafana, and other essential monitoring tools, providing approach to metrics collection, alerting, and visualization.

### Vikunja (Kustomize from Git):
Kubernetes manifests for Vikunja are stored in Git for version control and ease of management.
Kustomize is employed to tailor settings, allowing for a seamless transition between different environments, such as a fictional production database.

# Design Decisions
## Self-Hosted PostgreSQL with Bitnami's HA Helm Chart
I opted for a self-hosted PostgreSQL deployment utilizing Bitnami's HA Helm chart due to its flexibility and control over the database environment. 
While managed database services offer convenience and automated maintenance, a self-hosted approach allows for tailored configurations and fine-tuned performance optimizations. 
# Details on Keycloak IAM setup
- I configured the Keycloak instance using a Helm chart, customizing the deployment to align with specific requirements. 
I adjusting the database settings within the Helm chart to point to a PostgreSQL High Availability (HA) instance.
The Helm chart configured to use existing secrets options for PostgreSQL credentials which are created by "External Secret Operator". These CRD are also stored in GIT.
- I configured the Keycloak provider within the Vikunja API app. 
