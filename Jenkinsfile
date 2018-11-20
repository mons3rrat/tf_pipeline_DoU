import java.text.SimpleDateFormat

readProperties = loadConfigurationFile 'configFile'
currentBuild.displayName = new SimpleDateFormat("yy.MM.dd").format(new Date()) + "-" + env.BUILD_NUMBER

 pipeline {
    agent {
        docker {
            image readProperties.imagePipeline
            args '-v tf_plugins:/plugins'
        }
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
        TF_VAR_my_public_key_path = credentials('ssh-public-key')
        TF_VAR_my_private_key_path = credentials('ssh-private-key')
        TOKEN = credentials('gh-token')
        TF_PLUGIN_CACHE_DIR = '/plugins'
    }
    triggers {
         pollSCM('H/5 * * * *')
    }
    stages {
        stage('test & build'){
            when { expression{ env.BRANCH_NAME ==~ /feat.*/ } }
            steps {
                buildDockerImage readProperties.image
            }
        }
        stage('publish image'){
            when { expression{ env.BRANCH_NAME ==~ /feat.*/ } }
            steps {
                pushDockerImage readProperties.image
            }
        }
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
                createPR "jenkinsdou", readProperties.title, "dev", env.BRANCH_NAME, "gmlp"
                slackSend baseUrl: readProperties.slack, channel: '#devops_training_nov', color: '#00FF00', message: "Please review and approve PR to merge changes to dev branch : https://github.com/gmlp/tf_pipeline_DoU/pulls"
            }
        }

        stage('plan') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ || env.BRANCH_NAME ==~ /PR.*/ }}
            steps {
                sh 'cd terraform && terraform plan -out=plan -input=false'
                input(message: "Do you want to apply this plan?", ok: "yes")
            }
        }
        stage('apply') {
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ || env.BRANCH_NAME ==~ /PR.*/ }}
            steps {
                sh 'cd terraform && terraform apply -input=false plan'
            }
        }
        stage('deploy app'){
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ || env.BRANCH_NAME ==~ /PR.*/ }}

            steps {
                stackRollout readProperties.stackName, readProperties.stackFile
            }

        }
        stage('Integration Test'){
            when { expression{ env.BRANCH_NAME ==~ /dev.*/ || env.BRANCH_NAME ==~ /PR.*/ }}
            steps {
                echo 'running integration test'
            }

        }
        stage('destroy') {
            when { expression{ env.BRANCH_NAME ==~ /skip.*/ } }
            steps {
                sh 'cd terraform && terraform destroy -force -input=false'
            }
        }
    }
    post {
      success {
        slackSend baseUrl: readProperties.slack, channel: '#devops_training_nov', color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
      }
      failure {
        script{
          def commiter_user = sh "git log -1 --format='%ae'"
          slackSend baseUrl: readProperties.slack, channel: '#devops_training_nov', color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
        }
      }
      always {
            sh "docker system prune -f"
      }
    }
}
