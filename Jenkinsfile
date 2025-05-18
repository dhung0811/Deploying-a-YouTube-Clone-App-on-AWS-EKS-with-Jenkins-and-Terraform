def COLOR_MAP = [
    'FAILURE' : 'danger',
    'SUCCESS' : 'good'
]
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node24'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        NVD_API_KEY = credentials('NVD_API_KEY')
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/dhung0811/Deploying-a-YouTube-Clone-App-on-AWS-EKS-with-Jenkins-and-Terraform.git'
            }
        }
        stage('NPM Clean & Audit Fix') {
            steps {
                sh '''
            echo "Cleaning node_modules and package-lock.json"
            rm -rf node_modules package-lock.json

            echo "Installing fresh dependencies"
            npm install

            echo "Running npm audit fix"
            npm audit fix || true

            echo "Running npm audit fix --force"
            npm audit fix --force || true
        '''
            }
        }

        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=youtube \
                    -Dsonar.projectKey=youtube '''
                }
            }
        }   
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonarqube'
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --nvdApiKey=$NVD_API_KEY --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'Docker', toolName: 'Docker'){
                       sh "docker build --build-arg REACT_APP_RAPID_API_KEY='8b2cd34be7mshd945006b8a4b39fp1fe397jsn627a373b0e85' -t youtube ."
                       sh "docker tag youtube dhung0811/youtube:latest "
                       sh "docker push dhung0811/youtube:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image dhung0811/youtube:latest > trivyimage.txt"
            }
        }
        stage('Deploy to container'){
            steps{
                sh 'docker run -d --name youtube1 -p 3000:3000 dhung0811/youtube:latest'
            }
        }
        stage('Deploy to kubernets'){
            steps{
                withAWS(credentials: 'aws-key', region: 'us-east-1') {
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        sh 'kubectl apply -f deployment.yml'
                    }
                }
            }   }
        }

    }
    post {
    always {
        echo 'Slack Notifications'
        slackSend (
            channel: '#project-youtube-clone-app',
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} \n build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        )
    }
}
}

