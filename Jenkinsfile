pipeline {
  agent any

  environment {
    SONAR_HOST_URL = 'http://localhost:9000'
  }

  stages {

    stage('Backend - SonarQube') {
      steps {
        dir('backend') {
          withCredentials([string(credentialsId: 'sonar-backend-token', variable: 'SONAR_TOKEN')]) {
            withSonarQubeEnv('SonarQube') {
              sh '''
                mvn clean verify sonar:sonar \
                -Dsonar.projectKey=project-tracker-backend \
                -Dsonar.login=$SONAR_TOKEN
              '''
            }
          }
        }
      }
    }

    stage('Frontend - SonarQube') {
      steps {
        dir('frontend') {
          withCredentials([string(credentialsId: 'sonar-frontend-token', variable: 'SONAR_TOKEN')]) {
            sh '''
              flutter test
              sonar-scanner \
              -Dsonar.projectKey=project-tracker-frontend \
              -Dsonar.login=$SONAR_TOKEN \
              -Dsonar.host.url=http://localhost:9000
            '''
          }
        }
      }
    }
  }
}
