def ENVIRONMENT = ""

if (env.BRANCH_NAME == "develop") {
    ENVIRONMENT = "stage"
} else if (env.BRANCH_NAME == "main") {
    ENVIRONMENT = "prod"
} else {
    ENVIRONMENT = "dev"
}












pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'stage'], description: 'Select environment')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select action')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${ENVIRONMENT}") {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${ENVIRONMENT}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${ENVIRONMENT}") {
                        sh '''
                        terraform plan -out=tfplan
                        terraform show tfplan
                        '''
                    }
                }
            }
        }

        stage('Terraform Security Scan') {
    when {
        expression { params.ACTION == 'apply' }
    }
    steps {
        dir("environments/${ENVIRONMENT}") {
            sh '''
            tfsec . --soft-fail=false
            '''
        }
    }
}

       stage('Approval') {
    when {
        expression { ENVIRONMENT == 'stage' }
    }
    steps {
        input "Deploy to STAGE?"
    }
}

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${ENVIRONMENT}") {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' && params.ENV != 'prod' }
            }
            steps {
                input message: "Are you sure you want to DESTROY ${params.ENV}?"
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${ENVIRONMENT}") {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}