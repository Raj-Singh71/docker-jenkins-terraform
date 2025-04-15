pipeline {
    agent any

    environment {
        ACR_NAME = "mandacontainer2342423"
        IMAGE_NAME = "dockerimage"
        TAG = "latest"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_FULL_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${TAG}"
        RESOURCE_GROUP = "rg-aks"
        CLUSTER_NAME = "myAKSCluster"
        AZURE_CREDENTIALS = "azure-sp" // 👈 your Jenkins credentials ID for the Azure service principal
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: env.AZURE_CREDENTIALS,
                    subscriptionIdVariable: 'AZ_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZ_CLIENT_ID',
                    clientSecretVariable: 'AZ_CLIENT_SECRET',
                    tenantIdVariable: 'AZ_TENANT_ID'
                )]) {
                    bat 'az login --service-principal -u %AZ_CLIENT_ID% -p %AZ_CLIENT_SECRET% --tenant %AZ_TENANT_ID%'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('terra-jenk-docker') {
                    bat 'docker build -t %IMAGE_FULL_NAME% .'
                }
            }
        }

        stage('Login to ACR & Push Image') {
            steps {
                bat 'az acr login --name %ACR_NAME%'
                bat 'docker push %IMAGE_FULL_NAME%'
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat 'az aks get-credentials --resource-group %RESOURCE_GROUP% --name %CLUSTER_NAME% --overwrite-existing'
                bat 'kubectl apply -f deployment.yaml'
            }
        }
    }
}
