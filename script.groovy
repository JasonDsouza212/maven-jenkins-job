def buildApp() {
    echo 'building the app in groovy script'
}
def buildTest() {
    echo 'Testing the app in groovy script'
}

def buildDeploy() {
    echo 'Deploy the app in groovy script'
}
def buildJar() {
    echo "building the app"
    sh "mvn clean package"
}
def buildImage() {
     echo "building the docker image"
     withCredentials([usernamePassword(credentialsId: 'Dockerhub',usernameVariable: 'USER', passwordVariable: 'PASS')]){
     sh "docker build -t jasonkd006/my-repo:${IMAGE_NAME} ." || echo
     sh "echo $PASS | docker login -u $USER --password-stdin" || echo
     sh "docker push jasonkd006/my-repo:${IMAGE_NAME}" || echo
     }
}
return this
