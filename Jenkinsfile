pipeline {
    agent any
    // escenarios -> escenario -> pasos
    environment{
        NPM_CONFIG_CACHE= "${WORKSPACE}/.npm"
        dockerImagePrefix = "us-west1-docker.pkg.dev/lab-agibiz/docker-repository"
        registry = "https://us-west1-docker.pkg.dev"
        registryCredentials = "gcp-registry"
    }
    stages{
        stage ("saludo a usuario") {
            steps {
                sh 'echo "comenzado mi pipeline"'
            }
        }
        stage ("salida de los saludos a usuario") {
            steps {
                sh 'echo "saliendo de este grupo de escenarios"'
            }
        }
        stage ("proceso de build y test") {
            agent {
                docker {
                    image 'node:22'
                    reuseNode true
                }
            }
            stages {
                stage("instalacion de dependencias"){
                    steps {
                        sh 'npm ci'
                    }
                }
                stage("ejecucion de pruebas"){
                    steps {
                        sh 'npm run test:cov'
                    }
                }
                stage("construccion de la aplicacion"){
                    steps {
                        sh 'npm run build'
                    }
                }
            }
        }
         stage ("build y push de imagen docker"){
            steps {
                script {
                    docker.withRegistry("${registry}", registryCredentials ){
                        sh "docker build -t backend-nest-test-pcb ."
                        sh "docker tag backend-nest-test-pcb ${dockerImagePrefix}/backend-nest-test-pcb"
                        sh "docker tag backend-nest-test-pcb ${dockerImagePrefix}/backend-nest-test-pcb:${BUILD_NUMBER}"
                        sh "docker push ${dockerImagePrefix}/backend-nest-test-pcb"
                        sh "docker push ${dockerImagePrefix}/backend-nest-test-pcb:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage ("actualiza kubernets"){
            agent {
                docker {
                    image 'alpine/k8s:1.30.2'
                    reuseNode true
                }
            }
            steps {
                withKubeConfig([credentialsId: 'gcp-kubeconfig']){
                    sh "kubectl -n lab-pcb set image deployments/backend-nest-test-pcb backend-nest-test-pcb=${dockerImageName}/backend-nest-test-pcb:${BUILD_NUMBER}"
                }
            }
        }
    }
}
