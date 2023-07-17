pipeline {
    agent any
    parameters {
        choice choices: ["build","destroy"], description: "terraform action", name: "terraform_action"
        // string defaultValue: "", description: "", name: ""
    }
    tools { 
            maven 'Maven_3_5_2'  
        }
    stages{
        stage('CompileandRunSonarAnalysis') {
                steps {	
		            sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=asgbuggywebapp -Dsonar.organization=asgbuggywebapp -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=9325586a8f1d1adf470b908a46156f5844'
			}
        } 
  }

    stages {
        stage('checkout') {
            steps {
                git brach: 'main', url: 'git@github.com:0xsudo/NGINXPROJECT.git', credentialsid: 'jenkins_pk'
            }
        }
        stage('Docker Build') {
            steps {
                withDockerRegistry([credentialsId: 'docker-login', url: '']) {
                    script {
                        sh 'docker build -f nginx/Dockerfile -t nginx-image .'
                    }
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    sh 'docker push nginx-image:tag .'
                }
            }
        }
        stage('Terraform Action') {
            steps {
                script {
                    if (param.terraform_action == 'build') {
                        sh 'terraform -chdir=./terraform init'
                        sh 'terraform -chdir=./terraform apply --auto-approve'
                    } else {
                        sh 'terraform -chdir=./terraform apply --auto-approve'
                    }
                }
            }
        }
        stage('Wait For Deployment') {
            steps {
                script {
                    sh 'sleep 20'
                }
            }
        }
        stage('Ansible') {
            steps {
                script {
                    retry(count: 3) {
                        sh 'echo "GOOD"'
                        // sh 'ansible-playbook -i ansible/aws_instance ansible/ec2_playbook.yaml -vvv'
                    }
                }
            }
        }
    }
}

pipeline {
    agent any
    stages {
        stage("clone") {
            steps {
                git branch: 'main', credentialsId: '68e5f0a8-c14c-417e-8596-1844c6c98cf5', url: 'https://github.com/Adesam97/NODE-APP.git'
            }
        }
        
        stage("sonarcloud scanning") {
            environment {
                SONAR_SCANNER_VERSION = '4.7.0.2747'
                SONAR_SCANNER_HOME = "$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux"
                SONAR_TOKEN = "45ed842fba17abb771d1dbe51f38a26b2d8b39ea"
            }
            steps {
                script {
                    sh '''
                    curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip
                    unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
                    '''
                    sh '''
                    cd ./docker-node-app/
                    pwd
                    $HOME/.sonar/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner \
                  -Dsonar.organization=node-sonarcloud \
                  -Dsonar.projectKey=node-sonarcloud_first-node-check \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=https://sonarcloud.io
                    '''
                }
            }
        }
    }
}


sh 'sudo $HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux'
                sh '''sonar-scanner \\
                -Dsonar.organization=node-sonarcloud \\
                -Dsonar.projectKey=git-sonarcloud \\
                -Dsonar.sources=. \\
                -Dsonar.host.url=https://sonarcloud.io'''

        
        stage("scanning") {
            environment {
                SONAR_SCANNER_VERSION = '4.7.0.2747'
                SONAR_SCANNER_HOME = "$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-linux"
                SONAR_TOKEN = "7a5584c09f2a039f9ddd0da980e393e70cb8a15a"
            }
            steps {
                sh '''cd docker-node-app
                ls'''
                sh 'echo $PATH'
                sh ' ./$HOME/.sonar/sonar-scanner-4.7.0.2747-linux/bin/sonar-scanner'
                
            }
        }

