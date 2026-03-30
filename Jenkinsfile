pipeline {
agent any


environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    TF_ENV = ''
    TF_DIR = ''
    TF_VARS = ''
}

stages {

    stage('Setup Environment') {
        steps {
            script {
                if (env.CHANGE_ID || env.BRANCH_NAME == 'develop') {
                    env.TF_ENV = "dev"
                } else if (env.BRANCH_NAME == 'stage') {
                    env.TF_ENV = "stage"
                } else if (env.BRANCH_NAME == 'main') {
                    env.TF_ENV = "prod"
                }

                env.TF_DIR = "environments/${env.TF_ENV}"
                env.TF_VARS = "${env.TF_ENV}.tfvars"

                echo "Environment: ${env.TF_ENV}"
                echo "Directory: ${env.TF_DIR}"
            }
        }
    }

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Terraform Init') {
        steps {
            dir("${env.TF_DIR}") {
                sh 'terraform init'
            }
        }
    }

    stage('Terraform Validate') {
        steps {
            dir("${env.TF_DIR}") {
                sh 'terraform validate'
            }
        }
    }

    stage('Security Scan (tfsec)') {
        steps {
            dir("${env.TF_DIR}") {
                sh 'tfsec .'
            }
        }
    }

    stage('Terraform Plan (PR only)') {
        when {
            expression { return env.CHANGE_ID != null }
        }
        steps {
            dir("environments/dev") {
                sh 'terraform plan -var-file=dev.tfvars'
            }
        }
    }

    stage('Terraform Apply - Dev') {
        when {
            branch 'develop'
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Terraform Apply - Stage') {
        when {
            branch 'stage'
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Approval for Production') {
        when {
            branch 'main'
        }
        steps {
            input message: "Approve deployment to PRODUCTION?"
        }
    }

    stage('Terraform Apply - Prod') {
        when {
            branch 'main'
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }
}


}
