pipeline {
agent any


environment {
    AWS_DEFAULT_REGION = 'ap-south-1'
    TF_ENV  = ''
    TF_DIR  = ''
    TF_VARS = ''
}

stage('Setup Environment') {
steps {
script {


        def branch = env.BRANCH_NAME?.trim()

        echo "BRANCH_NAME = ${branch}"
        echo "CHANGE_ID   = ${env.CHANGE_ID}"

        if (env.CHANGE_ID) {
            env.TF_ENV = "dev"

        } else if (branch.contains("develop")) {
            env.TF_ENV = "dev"

        } else if (branch.contains("stage")) {
            env.TF_ENV = "stage"

        } else if (branch.contains("main")) {
            env.TF_ENV = "prod"

        } else {
            error "❌ Unsupported branch: ${branch}"
        }

        env.TF_DIR  = "environments/${env.TF_ENV}"
        env.TF_VARS = "${env.TF_ENV}.tfvars"

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
            expression { env.BRANCH_NAME?.contains("develop") }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Terraform Apply - Stage') {
        when {
            expression { env.BRANCH_NAME?.contains("stage") }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }

    stage('Approval for Production') {
        when {
            expression { env.BRANCH_NAME?.contains("main") }
        }
        steps {
            input message: "Approve deployment to PRODUCTION?"
        }
    }

    stage('Terraform Apply - Prod') {
        when {
            expression { env.BRANCH_NAME?.contains("main") }
        }
        steps {
            dir("${env.TF_DIR}") {
                sh "terraform apply -auto-approve -var-file=${env.TF_VARS}"
            }
        }
    }
}



