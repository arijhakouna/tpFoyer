pipeline {
    agent any

    environment {
        // Variables globales pour la version
        VERSION = ''
        TAG_VERSION = ''
    }

    stages {
        stage("Checkout & Tagging") {
            steps {
                echo "Checking out code and creating tag..."
                script {
                    // Checkout
                    git branch: 'master',
                        url: 'https://github.com/arijhakouna/tpFoyer.git'
                    
                    // Créer la version avec BUILD_NUMBER
                    def baseVersion = "5.0.1-SNAPSHOT"
                    def fullVersion = "${baseVersion}-${env.BUILD_NUMBER}"
                    
                    echo "Base version: ${baseVersion}"
                    echo "Full version: ${fullVersion}"
                    echo "Build number: ${env.BUILD_NUMBER}"
                    
                    // Mettre à jour le pom.xml avec la version complète
                    sh "mvn versions:set -DnewVersion=${fullVersion} -DgenerateBackupPoms=false"
                    
                    // Créer le tag Git avec la variable locale
                    sh "git add pom.xml"
                    sh "git commit -m 'Update version to ${fullVersion}' || true"
                    sh "git tag -a ${fullVersion} -m 'Release ${fullVersion}'"
                    sh "git push git@github.com:arijhakouna/tpFoyer.git ${fullVersion}"
                    
                    echo "Tag ${fullVersion} created and pushed successfully"
                    
                    // Assigner les variables d'environnement globalement
                    env.VERSION = fullVersion
                    env.TAG_VERSION = fullVersion
                    
                    echo "Environment variables set: VERSION=${env.VERSION}, TAG_VERSION=${env.TAG_VERSION}"
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
                script {
                    echo "Using VERSION: ${env.VERSION}"
                    echo "Using TAG_VERSION: ${env.TAG_VERSION}"
                    
                    sh """
                    docker build --build-arg VERSION=${env.VERSION} -t tpfoyer:${env.TAG_VERSION} .
                    docker tag tpfoyer:${env.TAG_VERSION} arijhakouna/tpfoyer:${env.TAG_VERSION}
                    docker login -u arijhakouna -p azerty123
                    docker push arijhakouna/tpfoyer:${env.TAG_VERSION}
                    """
                }
            }
        }

        stage("Docker Compose") {
            steps {
                echo "Deploying with Docker Compose..."
                script {
                    echo "Using DOCKER_TAG: ${env.TAG_VERSION}"
                    sh """
                    export DOCKER_TAG=${env.TAG_VERSION}
                    docker compose -f Docker-compose.yml up -d
                    docker ps -a
                    """
                }
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
