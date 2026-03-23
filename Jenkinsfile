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
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir("environments/${params.ENV}") {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Apply changes to ${params.ENV}?"
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
        expression { params.ACTION == 'destroy' }
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