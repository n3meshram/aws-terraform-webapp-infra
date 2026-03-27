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
                if (env.CHANGE_ID) {
                    dir('environments/dev') {
                        sh 'terraform init'
                    }
                } else if (env.BRANCH_NAME == 'develop') {
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

    stage('Terraform Validate') {
        steps {
            script {
                if (env.CHANGE_ID || env.BRANCH_NAME == 'develop') {
                    dir('environments/dev') {
                        sh 'terraform validate'
                    }
                } else if (env.BRANCH_NAME == 'main') {
                    dir('environments/prod') {
                        sh 'terraform validate'
                    }
                }
            }
        }
    }

    stage('Security Scan (tfsec)') {
        steps {
            script {
                if (env.CHANGE_ID || env.BRANCH_NAME == 'develop') {
                    dir('environments/dev') {
                        sh 'tfsec .'
                    }
                } else if (env.BRANCH_NAME == 'main') {
                    dir('environments/prod') {
                        sh 'tfsec .'
                    }
                }
            }
        }
    }

    stage('Terraform Plan (PR only)') {
        when {
            expression { return env.CHANGE_ID != null }
        }
        steps {
            dir('environments/dev') {
                sh 'terraform plan -var-file=dev.tfvars'
            }
        }
    }

    stage('Terraform Apply - Dev') {
        when {
            branch 'develop'
        }
        steps {
            dir('environments/dev') {
                sh 'terraform apply -auto-approve -var-file=dev.tfvars'
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
            dir('environments/prod') {
                sh 'terraform apply -auto-approve -var-file=prod.tfvars'
            }
        }
    }
}


}
