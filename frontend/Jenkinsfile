pipeline {
  agent any

  environment {
    SONAR_HOST_URL = 'http://localhost:9000'
  }

  stages {
    stage('SonarQube') {
      steps {
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
