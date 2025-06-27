pipeline {
    agent any

    environment {
        // Variables globales pour la version
        VERSION = ''
        TAG_VERSION = ''
    }

    stages {
        stage("Checkout") {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'master',
                    url: 'https://github.com/arijhakouna/tpFoyer.git'
            }
        }

        stage("Version & Tagging") {
            steps {
                echo "Creating version and tag..."
                script {
                    // Lire la version depuis pom.xml
                    def baseVersion = sh(
                        script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout',
                        returnStdout: true
                    ).trim()
                    
                    // Créer un tag unique avec BUILD_NUMBER
                    def tagVersion = "v${baseVersion}-${env.BUILD_NUMBER}"
                    env.VERSION = baseVersion
                    env.TAG_VERSION = tagVersion
                    
                    echo "Base version: ${baseVersion}"
                    echo "Tag version: ${env.TAG_VERSION}"
                    
                    // Créer le tag Git
                    sh "git tag -a ${env.TAG_VERSION} -m 'Release ${env.TAG_VERSION}'"
                    sh "git push origin ${env.TAG_VERSION}"
                    
                    echo "Tag ${env.TAG_VERSION} created successfully"
                }
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
                sh 'mvn deploy -DskipTests'
            }
        }

        stage("Docker") {
            steps {
                echo "Building and pushing Docker image..."
                sh """
                docker build -t tpfoyer:${env.TAG_VERSION} .
                docker tag tpfoyer:${env.TAG_VERSION} arijhakouna/tpfoyer:${env.TAG_VERSION}
                docker login -u arijhakouna -p azerty123
                docker push arijhakouna/tpfoyer:${env.TAG_VERSION}
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
            echo "Pipeline succeeded! Application deployed successfully with tag ${env.TAG_VERSION}"
        }
        failure {
            echo "Pipeline failed! Check the logs for details."
        }
    }
}
