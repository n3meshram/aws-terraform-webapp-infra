pipeline {
agent any

clear
environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
}

stages {

    stage('Setup Environment') {
        steps {
            script {

                def branch = env.BRANCH_NAME?.trim()
                def tfEnv = ""

                echo "BRANCH_NAME = ${branch}"
                echo "CHANGE_ID   = ${env.CHANGE_ID}"

                if (env.CHANGE_ID) {
                    // PR → always treat as dev plan
                    tfEnv = "dev"

                } else if (branch.contains("develop")) {
                    tfEnv = "dev"

                } else if (branch.contains("stage")) {
                    tfEnv = "stage"

                } else if (branch.contains("main")) {
                    tfEnv = "prod"

                } else {
                    error "❌ Unsupported branch: ${branch}"
                }

                env.TF_ENV  = tfEnv
                env.TF_DIR  = "environments/${tfEnv}"
                env.TF_VARS = "${tfEnv}.tfvars"

                echo "✅ TF_ENV  = ${env.TF_ENV}"
                echo "✅ TF_DIR  = ${env.TF_DIR}"
                echo "✅ TF_VARS = ${env.TF_VARS}"
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

    // ✅ PR → PLAN ONLY (NO APPLY)
    stage('Terraform Plan') {
        when {
            expression { env.CHANGE_ID != null }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform plan -var-file=${env.TF_VARS}"
            }
        }
    }

    // ✅ APPLY ONLY AFTER MERGE (NOT PR)
    stage('Terraform Apply - Dev') {
        when {
            expression {
                return env.BRANCH_NAME?.contains("develop") && env.CHANGE_ID == null
            }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Terraform Apply - Stage') {
        when {
            expression {
                return env.BRANCH_NAME?.contains("stage") && env.CHANGE_ID == null
            }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Approval for Production') {
        when {
            expression {
                return env.BRANCH_NAME?.contains("main") && env.CHANGE_ID == null
            }
        }
        steps {
            input message: "Approve deployment to PRODUCTION?"
        }
    }

    stage('Terraform Apply - Prod') {
        when {
            expression {
                return env.BRANCH_NAME?.contains("main") && env.CHANGE_ID == null
            }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }
}


}
