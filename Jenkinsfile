pipeline {
    agent any

    stages {
        stage("Git stage") {
            steps {
                echo "Pulling from GitHub..."
                git branch: 'master',
                    url: 'https://github.com/arijhakouna/tpFoyer.git'
            }
        }

        stage("MVN CLEAN") {
            steps {
                sh 'mvn clean'
            }
        }

        stage("MVN COMPILE") {
            steps {
                sh 'mvn compile'
            }
        }

        stage("MVN SONARQUBE") {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'mvn sonar:sonar'
                } 
            }
        }
        stage("MVN Test") {
            steps {
                sh 'mvn test'
            }
        }
        
        stage("Nexus") {
            steps {
                sh 'mvn deploy'
            }
        }
        stage("Building Image") {
            steps {
                sh """
                docker build -t tpfoyer:1.0.0 .
                docker tag tpfoyer:1.0.0 arijhakouna/tpfoyer:1.0.0
                docker login -u arijhakouna  -p azerty123
                docker push arijhakouna/tpfoyer:1.0.0
                """
            }
        }                
        stage("Deploy Image") {
            steps {
                sh 'docker compose -f Docker-compose.yml up -d  '
                sh 'docker ps -a'
            }
        }        
        
        
    }
}
