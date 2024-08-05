# Kubernetes voting app demo on AKS using Terraform and Jenkins

This code will deploy the 'Cats vs Dogs' demo voting pods into Azure kubernetes cluster. AKS cluster will be deployed using terraform and kubernetes will be deployed by Jenkins.



File structure:
```
├───Jenkinsfile-aks         # Jenkinsfile to create AKS cluster
├───Jenkinsfile-k8s         # Jenkinsfile to create deployments in kubernetes cluster
├───Jenkinsfile.minikube    # Deploy in Minikube
├───README.md               # This file
│
├───kubernetes              # Kubernetes deployment files
│       dp-test-namespace.yml
│       postgres-deployment.yml
│       postgres-service.yml
│       redis-deployment.yml
│       redis-service.yml
│       voting-fe-deployment.yml
│       voting-result-deployment.yml
│       voting-result-service.yml
│       voting-worker-deployment.yml
│
├───pods.bck                # Backup file (ignore)
│
└───terraform               # Terraform files for AKS cluster
        data.tf
        main.tf
        output.tf
        providers.tf
        variables.tf
```


## Steps 
1. Create Azure resource group (```demo-k8_group```).
2. Create Azure app resgistration and assign contributor role.
3. Add a client secret to app registration.
4. Add Azure credentials to Jenkins global credentials using 'AzureCredentials' plugin.
        [Declarative Pipeline](https://plugins.jenkins.io/azure-credentials/#plugin-content-declarative-pipeline) method was used and ```credentials-id``` was passed as env variable to Jenkinsfile-aks.
5. In Jenkins running machine, create folder ```my-folder-name``` and change ownership to jenkins user: ```chown -R jenkins:jenkins <my-folder-name>```
6. In Jenkinsfile-aks, this folder can be used to save terraform plan output.
7. In Jenkins, create 2 pipeline projects to create infrastructure (Select Jenkinsfile-aks) and deploy pods to cluster (Select Jenkinsfile-k8s).
8. Run the create infrastructure workflow to create AKS cluster.
9. From Jenkins machine, run ```read -sp "Azure password: " AZ_PASS && echo && az login --service-principal --tenant <tenant-id> -u <app-id> -p $AZ_PASS``` to login to Azure.
10. Run the following to set kubeconfig file to use kubernetes ```az aks get-credentials --resource-group <rg-name> --name dp-voting-app --overwrite-existing```
11. Add kube credentials to jenkins global credentials (Used [KubernetesCLI plugin](https://plugins.jenkins.io/kubernetes/#plugin-content-configuration)) Select kubeconfig file as SecretFile.
12. Run the Jenkinsfile-k8s to deploy deployments into kubernetes cluster.
13. Voting UI and results UI will be available through their external IPs ```kubectl get all -n dp-test```.






## Cleanup resources
1. ```kubectl delete all --all -n dp-test```
2. Go to ```my-folder-name``` ```terraform plan -destroy --out  "destroy.outfile.plan"```
3. ```terraform apply "destroy.outfile.plan"```
4. Check resource groups in Azure.
