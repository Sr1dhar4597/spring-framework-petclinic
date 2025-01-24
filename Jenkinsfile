pipeline {
  agent {
    docker {
      image 'abhishekf5/maven-abhishek-docker-agent:v1'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  stages {
    stage('Checkout') {
      steps {
        deleteDir() // Clean workspace
        git branch: 'main', url: 'https://github.com/Sr1dhar4597/spring-framework-petclinic.git'
        sh 'ls -ltr'
      }
    }
    stage('Build and Test') {
      steps {
        // Build and test the project
        sh './mvnw clean package -X'
      }
    }
    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://18.219.164.202:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
          sh './mvnw sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    stage('Build and Push Docker Image') {
      environment {
        DOCKER_IMAGE = "containerguru1/ultimate-cicd:${BUILD_NUMBER}"
      }
      steps {
        script {
          sh 'docker build -t ${DOCKER_IMAGE} .'
          docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
            def dockerImage = docker.image("${DOCKER_IMAGE}")
            dockerImage.push()
          }
        }
      }
    }
    stage('Update Deployment File') {
      steps {
        withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
          sh '''
              git config user.email "sridhar4597@gmail.com"
              git config user.name "Sr1dhar4597"
              sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" Petclinic-app-manifests/deployment.yml
              git add Petclinic-app-manifests/deployment.yml
              git commit -m "Update deployment image to version ${BUILD_NUMBER}"
              git push https://${GITHUB_TOKEN}@github.com/Sr1dhar4597/spring-framework-petclinic HEAD:main
          '''
        }
      }
    }
  }
}
