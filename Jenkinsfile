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
            script {
                if (env.BRANCH_NAME == 'develop') {
                    dir('environments/dev') {
                        sh 'terraform init'
                    }
                } else if (env.BRANCH_NAME == 'main') {
                    dir('environments/prod') {
                        sh 'terraform init'
                    }
                }
            }
        }
    }

    stage('Terraform Apply') {
        steps {
            script {
                if (env.BRANCH_NAME == 'develop') {
                    dir('environments/dev') {
                        sh 'terraform apply -auto-approve -var-file=dev.tfvars'
                    }
                } else if (env.BRANCH_NAME == 'main') {
                    dir('environments/prod') {
                        sh 'terraform apply -auto-approve -var-file=prod.tfvars'
                    }
                }
            }
        }
    }
}


}
