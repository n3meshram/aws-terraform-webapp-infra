pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-ssh',
                    branch: 'develop',
                    url: 'git@github.com:n3meshram/aws-terraform-webapp-infra.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('environments/dev') {
                    sh 'terraform init -reconfigure'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('environments/dev') {
                    sh 'terraform plan -var-file=terraform.tfvars'
                }
            }
        }
    }
}