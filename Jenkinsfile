pipeline {
    agent any 
    
    stages{
        // stage("Clone Code"){
        //     steps {
        //         echo "Cloning the code"
        //         git url:"https://github.com/LondheShubham153/django-notes-app.git", branch: "main"
        //     }
        // }
        stage("Build"){
            steps {
                echo "Building the image"
                sh "docker build . -t django-notes-app"
            }
        }
        // stage("Push"){
        //     steps {
        //         echo "Pushing the image to docker hub"
        //         withCredentials([usernamePassword(credentialsId:"dockerHub",passwordVariable:"dockerHubPass",usernameVariable:"dockerHubUser")]){
        //         sh "docker tag django-notes-app ${env.dockerHubUser}/django-notes-app:latest"
        //         sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass}"
        //         sh "docker push ${env.dockerHubUser}/my-note-app:latest"
        //         }
        //     }
        // }
        stage('Push'){
            steps{
                echo "Pushing the image to docker hub"
                withCredentials([usernamePassword(credentialsId:"Docker-Credentials", passwordVariable:"PASS", usernameVariable:"USER")]){
                    sh "docker image tag django-notes-app:latest ayushkrsingh/my-repository:django-notes-app"
                    sh "docker login -u ${env.USER} -p ${env.PASS}"
                    sh "docker push ayushkrsingh/my-repository:django-notes-app"
                }
            }
        }







        // stage("Deploy"){
        //     steps {
        //         echo "Deploying the container"
        //         sh "docker-compose down && docker-compose up -d"
                
        //     }
        // }



        stage('deploy'){
            steps{
                script{
                    // def dockerCmd = 'docker run -d -p 9000:8000 ayushkrsingh/my-repository:django-notes-app'
                    def dockerCmd = 'cd Django-Notes-App-Ci-CD && docker-compose down && docker-compose up -d'
                    def gitCmd1 = 'rm -rf Django-Notes-App-Ci-CD'
                    def gitCmd2 = 'git clone https://github.com/Ayush-K-Singh/Django-Notes-App-Ci-CD.git'
                    sshagent(['ec2-server-key']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@16.170.162.185 ${gitCmd1}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@16.170.162.185 ${gitCmd2}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@16.170.162.185 ${dockerCmd}"
                    }
                }
            }
        }
    }
}
