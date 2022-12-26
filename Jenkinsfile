def gv
pipeline{
    agent any 
 
    tools{
        maven 'maven3'
    }
    stages {
        stage("check"){
            steps{
                echo "just checking"
            }
        }
    
        stage("init"){
         steps{
               script{
                gv=load "script.groovy"
            }
         }
        }
        stage("increment-version"){
            steps{
                script{
                    echo "Incrementing Version to next version"
                    sh "mvn build-helper:parse-version versions:set \
                    -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                    versions:commit"
                   def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                   def version = matcher[0][1]
                   env.IMAGE_NAME ="$version-$BUILD_NUMBER"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    gv.buildJar()

                }
            }
        }
        stage("build image") {
            steps {
                script {
                    gv.buildImage()
                }
            }
      }
      stage('provision server'){
            environment {
                AWS_ACCESS_KEY_ID= credentials("jenkins_aws_access_key_id")
                AWS_SECRET_ACCESS_KEY=credentials("jenkins_aws_access_key")
                TF_VAR_env_prefix="test"
            }
            steps {
                script {
                    dir('terraform'){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                       EC2_PUBLIC_IP =sh(
                        script: "terraform output ec2_public_ip",
                        returnStdout: true
                       ).trim()
                    }
                }    
            }
        }

        stage("deploy") {
            environment{
                DOCKER_CREDS=credentials('docker-hub-repo')
            }
          steps{
                script {
                    echo "waiting for EC@ server to initialize"
                    sleep(time:90,unit:"SECONDS") //can optimise this

                    echo "deploying docker image to EC2..."
                    echo "${EC2_PUBLIC_IP}"
                    // def dockerCmd= "docker run -p 3080:3080 -d jasonkd006/my-repo:${IMAGE_NAME}"
                    def dockerComposeCmd ="bash ./servercmds.sh jasonkd006/my-repo:${IMAGE_NAME} ${DOCKER_CREDS_USR}  ${DOCKER_CREDS_PSW}"
                    // def dockerComposeCmd ="docker-compose -f docker-compose.yaml up --detach"
                   sshagent(['server-ssh-key']) {
                          sh "scp servercmds.sh ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user"
                         sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ec2-user@35.154.71.70:/home/ec2-user"
                         sh "ssh -o StrictHostKeyChecking=no ec2-user@35.154.71.70 ${dockerComposeCmd}"
                        }
                   
                }
          }
        }
  
        stage('deploy-2') {
            environment {
                AWS_ACCESS_KEY_ID =credentials('jenkins_aws_accesskey_id')
                AWS_SECRET_ACCESS_KEY =credentials('jenkins_aws_secret_access_key')
                APP_NAME = 'java-maven-app'
            }
            steps {
                script {
                      echo 'deploying docker image'
                      sh 'envsubst < kubernetes/deployment.yaml | kubectl apply -f -'
                      sh 'envsubst < kubernetes/service.yaml | kubectl apply -f -'
                } 
            }
        }
        // stage('commit version update'){
        //     steps{
        //         script{
        //               withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable:'PASS', usernameVariable: 'USER' )]){
        //                 sh 'git config --global user.email "jasondsouza212@gmail.com"'
        //                 sh 'git config --global user.name "jenkins"'
                        
        //                 sh 'git status'
        //                 sh 'git branch'
        //                 sh 'git config --list'
                        
        //                 // sh "git remote set-url origin https://${USER}:${PASS}@github.com/JasonDsouza212/maven-jenkins-job-dockerfil.git"
        //                 sh 'git remote add origin "https://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@github.com/JasonDsouza212/maven-jenkins-job-dockerfil.git"'
        //                 sh "git add ."
        //                 sh 'git commit -m "the new version is added"'
        //                 sh 'git push origin HEAD:main'
        //            }
        //         }
        //     }
        // }
    }
    }
