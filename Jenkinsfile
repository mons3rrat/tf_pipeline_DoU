def DEV_BRANCH = "dev" 
def MESSAGE = "PR Created Automatically by Jenkins \n" 
 pipeline {
    agent {
        docker {
            image 'gmlpdou/terraform_hub:0.11.10'
        }
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
        TF_VAR_my_public_key_path = credentials('ssh-public-key')
        TF_VAR_my_private_key_path = credentials('ssh-private-key')
        TOKEN = credentials('gh-token')
    }
    triggers {
         pollSCM('H/5 * * * *')
    }
    stages {
        stage('init') {
            steps {
                // send build started notifications
                // slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
                sh 'cd terraform && terraform init -input=false'
            }
        }
        stage('validate') {
            when { expression{ env.BRANCH_NAME ==~ /feat.*/ } }
            steps {
                sh 'cd terraform && terraform validate'
            }
        }
        stage('generate pr') {
            when { expression{ env.BRANCH_NAME ==~ /feat.*/ } }
            steps {
                script {
                    def COMMIT_MESSAGE = sh(script:'git log -1 --pretty=%B', 
                        returnStdout: true).trim() 
                    sh 'mkdir ~/.config'
                    sh 'echo "github.com:" >> ~/.config/hub'
                    sh 'echo "- user: jenkinsdou" >> ~/.config/hub'
                    sh "echo \"  oauth_token: ${env.TOKEN}\" >> ~/.config/hub"
                    sh 'echo "  protocol: https" >> ~/.config/hub'
                    try {
                        sh "hub pull-request -m \"${MESSAGE} ${COMMIT_MESSAGE} \" -b gmlp:${DEV_BRANCH} -h gmlp:${env.BRANCH_NAME}"
                    }catch(Exception e) {
                        echo "PR already created"
                    }
                    
                }
            }
        }
        
        stage('plan') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ } }
            steps {
                sh 'cd terrform && terraform plan -out=plan -input=false'
                input(message: "Do you want to apply this plan?", ok: "yes")
            }
        }
        stage('apply') {
            when { 
                expression{ env.BRANCH_NAME ==~ /dev.*/ }
            }
            steps {
                sh 'cd terraform && terraform apply -input=false plan'
            }
        }
        stage('destroy') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ } }
            steps {
                sh 'cd terraform && terraform destroy -force -input=false'
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
