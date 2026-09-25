pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "crow-helloworld-app"
        DOCKER_TAG   = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== KROK 1: Pobranie kodu z repozytorium ==='
                checkout scm
            }
        }

        stage('Smoke Testy') {
            steps {
                echo '=== KROK 2: Weryfikacja czy Dockerfile istnieje ==='
                sh 'test -f Dockerfile && echo "Dockerfile obecny." || (echo "Brak pliku Dockerfile!" && exit 1)'
            }
        }

        stage('Budowanie Dockera') {
            steps {
                echo "=== KROK 3: Budowanie obrazu produkcyjnego ==="
                // Zbuduj obraz lokalnie z unikalnym tagiem z builda oraz 'latest'. Jedna komenda buduje obraz tylko raz.
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest ."
            }
        }
        
        stage('Testy') {
            steps {
                echo '=== KROK 4: Test uruchomieniowy kontenera ==='
                // Po uruchomieniu sprawdź, czy żyje (grep)
                sh """
                    docker run -d --name test_app_${DOCKER_TAG} -p 18080:18080 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    sleep 3
                    docker ps | grep test_app_${DOCKER_TAG}
                    docker stop test_app_${DOCKER_TAG}
                    docker rm test_app_${DOCKER_TAG}
                """
            }
        }
    }

    post {
        always {
            echo '=== KROK 5: Clean-up ==='
            // Na wypaek, gdyby wcześniej nie został usunięty z systemu.
            sh "docker rm -f test_app_${DOCKER_TAG} 2>/dev/null || true"
        }
        success {
            echo "Sukces! Obraz ${DOCKER_IMAGE}:${DOCKER_TAG} został pomyślnie zbudowany i przetestowany lokalnie."
        }
        failure {
            echo "Failure! Sprawdź logi."
        }
    }
}

