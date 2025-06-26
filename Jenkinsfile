pipeline {
    agent any

    stages {
        stage("Checkout") {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'master',
                    url: 'https://github.com/arijhakouna/tpFoyer.git'
            }
        }

        stage("Clean & Compile") {
            steps {
                echo "Cleaning and compiling the project..."
                sh 'mvn clean compile'
            }
        }

        stage("Unit Tests") {
            steps {
                echo "Running Unit Tests..."
                sh 'mvn test -Dtest="*ServiceTest,*RestControllerTest" -DfailIfNoTests=false'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
//hello

        stage("Integration Tests") {
            steps {
                echo "Running Integration Tests..."
                sh 'mvn test -Dtest="*IntegrationTest" -DfailIfNoTests=false'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage("SonarQube") {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage("Nexus") {
            steps {
                echo "Deploying to Nexus repository..."
                sh 'mvn deploy'
            }
        }

        stage("Docker") {
            steps {
                echo "Building and pushing Docker image..."
                sh """
                docker build -t tpfoyer:1.0.0 .
                docker tag tpfoyer:1.0.0 arijhakouna/tpfoyer:1.0.0
                docker login -u arijhakouna -p azerty123
                docker push arijhakouna/tpfoyer:1.0.0
                """
            }
        }

        stage("Docker Compose") {
            steps {
                echo "Deploying with Docker Compose..."
                sh 'docker compose -f Docker-compose.yml up -d'
                sh 'docker ps -a'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed with result: ${currentBuild.result}"
        }
        success {
            echo " Pipeline succeeded! Application deployed successfully."
        }
        failure {
            echo " Pipeline failed! Check the logs for details."
        }
    }
}
