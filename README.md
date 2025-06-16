# Deploying a YouTube Clone App on AWS EKS with Jenkins and Terraform
This repository contains the code and instructions to deploy a YouTube clone application on AWS EKS using Jenkins and Terraform. The application is built with React, Node.js.

The project is designed to demonstrate the use of AWS EKS for container orchestration, Jenkins for CI/CD, and Terraform for infrastructure as code and based on the YouTube clone application from [this repository](https://github.com/uniquesreedhar/Youtube-clone-app).
# Prerequisites
- AWS account
- AWS CLI installed and configured
- Terraform installed

# Workflow
## The workflow for this project is as follows:

![Workflow](/img/DevSecOps_final.png)
### CI Pipeline Steps
1. **Code Commit**: Developers commit code to the GitHub repository.
2. **Jenkins Pipeline**: Jenkins is triggered by the code commit.
3. **Build and Test**: Jenkins builds the application and runs tests.
4. **Docker Image Creation**: Jenkins creates a Docker image of the application.
5. **SonarQube Analysis**: Jenkins runs SonarQube to analyze the code quality.
6. **If Analysis Fails**: If the SonarQube analysis fails, Jenkins stops the pipeline.
7. **If Analysis Passes**: If the SonarQube analysis passes, Jenkins builds the Docker image.
8. **Scan with Trivy**: Jenkins scans the Docker image with Trivy for vulnerabilities.
9. **If Vulnerabilities Found**: If vulnerabilities are found, Jenkins stops the pipeline.
10. **If No Vulnerabilities**: If no vulnerabilities are found, Jenkins pushes the Docker image to the Docker Hub.
11. **Send Notification**: Jenkins sends a slack notification to the team about the build status.
### CD Pipeline Steps
12. **Terraform Apply**: Jenkins runs Terraform to apply the infrastructure changes.
13. **Deploy to EKS**: Jenkins deploys the Docker image to AWS EKS.

## The AWS infrastructure is defined using Terraform and includes the following components:
![AWS Infrastructure](/img/AWS-Data.jpg)


# Getting Started
## Create infrastructure to use Jenkins and SonarQube on AWS EC2 instance:
Move to Jenkins-SonarQube-Server directory and run the following commands:
```bash
terraform init
terraform plan
treraform apply
```
After running the above commands, you will have a Jenkins and SonarQube server running on AWS EC2 instance. You can access Jenkins at `http://<EC2_PUBLIC_IP>:8080` and SonarQube at `http://<EC2_PUBLIC_IP>:9000`.
![DoneJenkins](/img/DoneJenkins.png)


![DoneSonarQube](/img/DoneSonar.png)
## Configure Jenkins
1. Open Jenkins in your browser.
2. Install the required plugins:
    - Eclipse Temurin Installer 
    - SonarQube Scanner 
    - NodeJs Plugin 
    - NodeJs Plugin 
    - Docker
    - Docker commons
    - Docker pipeline
    - Docker API
    - Docker Build step
    - Owasp Dependency Check
    - Terraform
    - Kubernetes
    - Kubernetes CLI
    - Kubernetes Client API
    - Kubernetes Pipeline DevOps steps
    - AWS Credentials
    - Pipeline: AWS Steps
    - Slack notifications
![installPlugins](/img/installPlugins.png)
3. Configure the following tools in Jenkins:
    - Configure the necessary tools in Jenkins:
         - **jdk17:**
![Config JDK](/img/configJDK.png)
        - **NodeJS24.0.2**
![Config NodeJS](/img/configNodeJS.png)
        - **SonarQube Scanner**
![Add Sonar Server](/img/configSonar-scanner.png)
        - **DP Check**
![Add DP Check](/img/configDP-Check.png)
        - **Docker**
![Config Docker](/img/configDocker.png)
4. Configure the AWS credentials in Jenkins:
    - Go to `Manage Jenkins` > `Manage Credentials` > `Global` > `Add Credentials`.
    - AWS
![AWS credential](/img/addAWSCredentials.png)
    - GitHub
![GitHub credential](/img/addGithubCredentials.png)
    - Sonar-token
![Sonarqube credential](/img/addSonarCredentials.png)
    - Docker
![Docker credential](/img/addDockerCredentials.png)
5. Configure the SonarQube server:
![DoneSonarQube](/img/DoneSonar.png)
Login to SonarQube at `http://<EC2_PUBLIC_IP>:9000` with the default credentials (admin/admin) and change the password. Then, generate a token.
Go Administration → Security → Users → Tokens and Update Token → Define the Token → Generate Token.
![Create Token For Jenkins On Sonar](/img/createTokenForJenkinsOnSonar.png)
6. Create webhook in SonarQube:
   - Go to `Project Settings` > `Webhooks`.
   - Add a new webhook with the URL `http://<EC2_PUBLIC_IP>:8080/sonarqube-webhook/`.
![Create Webhook](/img/createWebhookForJenkinsOnSonar.png)
7. Integrate Slack with Jenkins:
   - Go to slack and create a new workspace or use an existing one.
   - Add JenkinsCI app to your Slack workspace.
   ![Add JenkinsCI to Slack](/img/addJenkinsIntoSlack.png)
8. Create Slack app and get the token:
   - Go to `https://api.slack.com/apps` and create a new app.
   - Add the `chat:write` permission to the app.
   - Install the app to your workspace and get the OAuth token.
9. Configure Slack in Jenkins:
   - Go to `Manage Jenkins` > `Credentials` > `Global` > `Add Credentials`.
   - Select `Secret text` and enter the Slack token.
   ![Add Slack Credentials](/img/addSlackCredentials.png)
   - Go to `Manage Jenkins` > `Configure System`.
   - Scroll down to the `Slack` section and enter the following details:
     - Workspace: Your Slack workspace name.
     - Credential: Select the Slack token you created earlier.
     - Default channel: The channel where you want to send notifications.
   ![Configure Slack in Jenkins](/img/configSlack.png)
     - Test the Slack configuration by clicking on the `Test Connection` button.
   ![Test Slack Connection](/img/configSlackSuccessfully.png)
10. Create an API key from Rapid API:
    - Go to `https://rapidapi.com/` and create an account or log in.
    - Search for the YouTube Data API and subscribe to it.
    - Get the API key from the dashboard.
    ![getRapidAPIKey](/img/getAPIToken.png)
11. Create a new pipeline in Jenkins:
    - Go to `Jenkins` > `New Item`.
    - Enter a name for the job and select `Pipeline`.
    - In the pipeline configuration, set the following:
      - Definition: Pipeline script from SCM
      - SCM: Git
      - Repository URL: `your-github-repo-url`
    ![Create Pipeline Job](/img/createPipeline.png)
12. Run the pipeline:
    - Click on `Build Now` to run the pipeline.
    - Monitor the build progress in the Jenkins console.
    ![Run Pipeline](/img/doneCIPipeline.png)
    - Once the pipeline is successful, you test the application by accessing the the IP `http://<EC2_PUBLIC_IP>:3000`.
    ![Deployed using Docker](/img/deployusingdocker.png)
13. Create Pipeline for create EKS cluster.
    - Create a new pipeline in Jenkins: use the same configuration as above, but use the `JenkinsFile-EKS-Terraform` script from the repository.
    ![Create EKS Pipeline](/img/createPipelineToCreateEKS.png)
    - After running the pipeline, you will have an EKS cluster created with the necessary resources.
    ![doneEKS](/img/createdEKS.png)
14. Configure kubectl to access the EKS cluster:
    - Install the AWS CLI and kubectl.
    - Run the following commands to configure kubectl:
    ```bash
    aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
    ```
    - Verify the connection by running:
    ```bash
    kubectl get nodes
    ```
    ![verifyEKS](/img/createdNodes.png)
    Open ~/.kube/config and check the users: section. Copy the certificate-authority-data and add it to the Jenkins credentials as a secret text to use it in the pipeline.
    ![getcertificate](/img/getK8sCert.png)
15. Add the deploy stage to the previous pipeline:
    ```groovy
    stage('Deploy to kubernets'){
            steps{
                withAWS(credentials: 'aws-key', region: 'us-east-1') {
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        sh 'kubectl apply -f deployment.yml'
                    }
                }
            }   
        }
    }
    ```
16. Run the pipeline:
![Run the pipeline](/img/donePipeline.png)
    - After running the pipeline, you will have the application deployed on EKS, and a LoadBalancer created.
    ![Access Application](/img/createdLB.png)
    - You can access the application using the LoadBalancer IP or the NodePort.
    ![deployedApp](/img/deploySuccessful.png)
    ![testApp](/img/testDeployment.png)
17. Clean up resources:
    - To clean up the EKS cluster, run the pipeline with the 'destroy' option.
    - To clean up the resources created by Terraform, run the following command in the `Jenkins-SonarQube-Server` directory:
    ```bash
    terraform destroy
    ```
    

