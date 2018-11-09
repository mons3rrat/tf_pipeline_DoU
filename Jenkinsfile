pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:0.11.10'
            args '--entrypoint=""'
        }
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
        TF_VAR_my_public_key_path = credentials('ssh-public-key')
        TF_VAR_my_private_key_path = credentials('ssh-private-key')
    }
    triggers {
         pollSCM('H/5 * * * *')
    }
    stages {
        stage('init') {
            steps {
                // send build started notifications
                // slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                sh 'terraform init -input=false'
            }
        }
        stage('verify') {
            when { env.BRANCH_NAME == 'feat*'}
            steps {
                sh 'terraform verify'
            }
        }
        
        stage('plan') {
            when { env.BRANCH_NAME == 'dev*'}
            steps {
                sh 'terraform plan -out=plan -input=false'
                input(message: "Do you want to apply this plan?", ok: "yes")
            }
        }
        stage('apply') {
            when { env.BRANCH_NAME == 'dev*'}
            }
        }
        stage('destroy') {
            when { env.BRANCH_NAME == 'dev*'}
            steps {
                sh 'terraform destroy -force -input=false'
            }
        }
    }
   // post {
   //     success {
   //         slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
   //     }
   //     failure {
   //         slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")

   //     }
   // }
}
