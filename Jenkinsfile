pipeline {
    agent any 
    
    stages{
        stage("Build"){
            steps {
                echo "Building the image"
                sh "docker build . -t django-notes-app"
            }
        }

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

        stage('Provision'){
            environment{
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key')
                AWS_SECRET_ACCESS_ID = credentials('jenkins_aws_secret_key')
            }
            steps{
                echo "Provisioning Infrastructure on AWS"
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

        stage('Deploy'){
            steps{
                script{
                    echo "Waiting for instance to get initialized"
                    sleep(90)

                    echo "Deploying application on the provisioned instance"
                    
                    def dockerCmd1 = 'docker-compose -f Django-Notes-App-Ci-CD/docker-compose.yml down'
                    def gitCmd1 = 'rm -rf Django-Notes-App-Ci-CD'
                    def gitCmd2 = 'git clone https://github.com/Ayush-K-Singh/Django-Notes-App-Ci-CD.git'
                    def dockerCmd2 = 'docker-compose -f Django-Notes-App-Ci-CD/docker-compose.yml up -d'
                    sshagent(['aws-keypair']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd1}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${gitCmd1}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${gitCmd2}"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_PUBLIC_IP} ${dockerCmd2}"
                    }
                }
            }
        }
    }
}
