pipeline{
    agent any 

    stages {
        stage("coy files to ansible server"){
            steps{
               script {
                    echo "Copying all neccessary files to ansible node"
                    sshagent(['ansibles-erver-key']) {
                        sh "scp -o StrictHostKeyChecking=no ansible/* ec2-user@_ip_address:/root"

                        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-server-key' , keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                           sh 'scp $keyfile ec2-user@_ip_address:/root/ssh-key.pem' //the same way is secured way to copy ssh keys
                        }
                    }
               }
            }
        }
        stage("execute ansible playbook"){
            steps {
                script {
                    echo "calling ansible playbook to configure ec2 instance"
                    def remote = [:]
                    remote.name ="ansible-server"
                    remote.host ="Ip_address"
                    remote.allowAnyHosts =true
                    // ssh pipeline plugin
                    withCredentials([sshUserPrivateKey(credentialsId: 'ansible-server-key' , keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                         remote.user = user
                         remote.identityFile = keyfile
                         sshScript remote: remote, script: "prepare-ansible-server.sh"
                         sshCommand remote:remote, command: "ansible-playbook my-playbook.yaml"
                    }
                    
                   
                }
            }
        }
    }
}
