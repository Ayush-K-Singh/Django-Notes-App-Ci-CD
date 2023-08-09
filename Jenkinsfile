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
        stage('provision'){
            environment{
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key')
                AWS_SECRET_ACCESS_ID = credentials('jenkins_aws_secret_key')
            }
            steps{
                script{
                    sh "terraform init"
                    sh "terraform plan"
                    sh "terraform apply --auto-approve"
                    AWS_EC2_PUBLIC_IP = sh(
                        script: "terraform output aws_ec2_instance_ip",
                        returnStdout: true
                    ).trim()
                }
            }
        }



        stage('deploy'){
            steps{



                script{
                    echo "Wait for instance"
                    sleep(90)

                    echo "Started deploying"
                    
                    // def dockerCmd = 'docker run -d -p 9000:8000 ayushkrsingh/my-repository:django-notes-app'
                    def dockerCmd = 'docker-compose --version'
                    def dockerCmd1 = 'cd Django-Notes-App-Ci-CD'
                    def dockerCmd11 = 'docker-compose down'
                    def dockerCmd2 = 'cd Django-Notes-App-Ci-CD && docker-compose up -d'
                    def gitCmd1 = 'rm -rf Django-Notes-App-Ci-CD'
                    def gitCmd2 = 'git clone https://github.com/Ayush-K-Singh/Django-Notes-App-Ci-CD.git'
                    sshagent(['aws-keypair']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd1}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd11}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${gitCmd1}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${gitCmd2}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd2}"
                    }
                }
            }
        }
    }
}
