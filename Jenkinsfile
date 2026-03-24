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
                    dir("environments/${params.ENV}") {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENV}") {
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
                    dir("environments/${params.ENV}") {
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
        dir("environments/${params.ENV}") {
            sh '''
            tfsec . --soft-fail=false
            '''
        }
    }
}

        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                input message: "Review plan above. Apply changes to ${params.ENV}?"
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${params.ENV}") {
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
                    dir("environments/${params.ENV}") {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}