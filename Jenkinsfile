pipeline {
agent any


environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Terraform Init') {
        steps {
            dir('environments/dev') {
                sh 'terraform init'
            }
        }
    }

    stage('Terraform Validate') {
        steps {
            dir('environments/dev') {
                sh 'terraform validate'
            }
        }
    }

    stage('Terraform Plan') {
        steps {
            dir('environments/dev') {
                sh 'terraform plan -var-file=dev.tfvars'
            }
        }
    }
}


}
