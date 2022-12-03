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
        stage("deploy") {
          steps{
                script {
                    // def dockerCmd= "docker run -p 3080:3080 -d jasonkd006/my-repo:${IMAGE_NAME}"
                    def dockerComposeCmd ="bash ./servercmds.sh jasonkd006/my-repo:${IMAGE_NAME}"
                    // def dockerComposeCmd ="docker-compose -f docker-compose.yaml up --detach"
                   sshagent(['awscredential']) {
                          sh "scp servercmds.sh ec2-user@35.154.71.70:/home/ec2-user"
                         sh "scp docker-compose.yaml ec2-user@35.154.71.70:/home/ec2-user"
                         sh "ssh -o StrictHostKeyChecking=no ec2-user@35.154.71.70 ${dockerComposeCmd}"
                        }
                   
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
