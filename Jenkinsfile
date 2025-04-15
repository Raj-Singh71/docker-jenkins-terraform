pipeline {
    agent any

    environment {
        ACR_NAME         = "mandacontainer2342423"
        IMAGE_NAME       = "dockerimage"
        TAG              = "latest"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_FULL_NAME  = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${TAG}"
        RESOURCE_GROUP   = "rg-aks"
        CLUSTER_NAME     = "myAKSCluster"
    }

    stages {

        stage('Load Azure Credentials') {
            steps {
                withCredentials([string(credentialsId: 'AZURE_CREDENTIALS', variable: 'AZURE_CREDS_JSON')]) {
                    script {
                        def creds = readJSON text: AZURE_CREDS_JSON
                        env.ARM_CLIENT_ID       = creds.clientId
                        env.ARM_CLIENT_SECRET   = creds.clientSecret
                        env.ARM_SUBSCRIPTION_ID = creds.subscriptionId
                        env.ARM_TENANT_ID       = creds.tenantId
                    }
                }
            }
        }

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
                bat '''
                az login --service-principal -u %ARM_CLIENT_ID% -p %ARM_CLIENT_SECRET% --tenant %ARM_TENANT_ID%
                az account set --subscription %ARM_SUBSCRIPTION_ID%
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %IMAGE_FULL_NAME% ."
            }
        }

        stage('Login to ACR & Push Image') {
            steps {
                bat '''
                az acr login --name %ACR_NAME%
                docker push %IMAGE_FULL_NAME%
                '''
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat '''
                az aks get-credentials --resource-group %RESOURCE_GROUP% --name %CLUSTER_NAME% --overwrite-existing
                kubectl apply -f deployment/deployment.yaml
                '''
            }
        }
    }
}
