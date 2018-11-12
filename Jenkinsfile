readProperties = loadConfigurationFile 'configFile'
 pipeline {
    agent {
        docker {
            image readProperties.image
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
                createPR "jenkinsdou", "PR Created Automatically by Jenkins", "dev", env.BRANCH_NAME, "gmlp"
            }
        }

        stage('plan') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ } }
            steps {
                sh 'cd terrform && terraform plan -out=plan -input=false'
                emailext subject: "Approval manual steps", to: readProperties.emailApprovers, body:"Please approve or abort plant promotion using the enclosed link"
                input(message: "Do you want to apply this plan?", ok: "yes")
            }
        }
        stage('apply') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ } }
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
    post {
      success {
        emailext subject: "SUCCESSFUL: Job ${env.JOB_NAME}", to: readProperties.emailApprovers, body: """All,
                  Build job# ${env.BUILD_NUMBER}  has finished successfully.
                  URL_JOB: ${env.BUILD_URL}

                  Regards,
                  DevOps
                  """
      }
      failure {
        script{
          def commiter_user = sh "git log -1 --format='%ae'"
          emailext subject: "FAILED: Job ${env.JOB_NAME}", to: "${commiter_user}", body: "${env.BUILD_URL}"
        }
      }
    }
}
