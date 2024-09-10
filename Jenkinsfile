import org.yaml.snakeyaml.Yaml

pipeline {
    agent { label 'Linux' }

    parameters {
        choice(name: 'REGION', choices: ['NA', 'UK', 'EMEA', 'APAC'], description: 'Select the Region to deploy to')
        choice(name: 'ENVIRONMENT', choices: ['Dev', 'Stage', 'Prod', 'Sbx'], description: 'Select the Environment to deploy to')
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Name of the branch')
        choice(name: 'ACTION', choices: ['create', 'destroy'], description: 'Action to perform: create or destroy')
        string(name: 'RESOURCE_NAME', defaultValue: 'example_resource', description: 'Name of the resource to apply Terragrunt to')
    }

    environment {
        BASE_DIR = "${params.ENVIRONMENT}/eec-aws-${params.REGION}-eits-egpt-${params.ENVIRONMENT}/${params.REGION}/modules/"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Load Configurations') {
            steps {
                script {
                    // Define the configuration map for roles and external IDs within the Jenkinsfile
                    def configMap = [
                        'NA'   : [
                            'Dev'   : [roleAccount: "role-account-dev", externalId: "external-id-dev", s3Bucket: "na-dev-bucket", subfolder: "na/dev/"],
                            'Prod'  : [roleAccount: "role-account-prod", externalId: "external-id-prod", s3Bucket: "na-prod-bucket", subfolder: "na/prod/"]
                        ],
                        'UK'   : [
                            'Dev'   : [roleAccount: "role-account-uk-dev", externalId: "external-id-uk-dev", s3Bucket: "uk-dev-bucket", subfolder: "uk/dev/"],
                            'Prod'  : [roleAccount: "role-account-uk-prod", externalId: "external-id-uk-prod", s3Bucket: "uk-prod-bucket", subfolder: "uk/prod/"]
                        ]
                    ]

                    def key = "${params.REGION}-${params.ENVIRONMENT}"
                    def config = configMap[params.REGION][params.ENVIRONMENT]

                    if (!config) {
                        error "No configuration found for ${params.REGION} - ${params.ENVIRONMENT}"
                    }

                    env.S3_BUCKET = config.s3Bucket
                    env.ROLE_ACCOUNT = config.roleAccount
                    env.EXTERNAL_ID = config.externalId
                    env.SUBFOLDER = config.subfolder

                    echo "Loaded configurations: ROLE_ACCOUNT=${env.ROLE_ACCOUNT}, EXTERNAL_ID=${env.EXTERNAL_ID}, S3_BUCKET=${env.S3_BUCKET}"
                }
            }
        }

        stage('Prepare Terragrunt Directory') {
            steps {
                script {
                    def target_dir = "${env.BASE_DIR}${params.RESOURCE_NAME}"

                    if (!fileExists(target_dir)) {
                        error "Directory ${target_dir} does not exist."
                    }

                    echo "Changing directory to ${target_dir}"
                    dir(target_dir) {
                        echo "Running in ${pwd()}"
                    }
                }
            }
        }

        stage('Set AWS Environment Variables') {
            steps {
                script {
                    // Keep the export commands for AWS_PROFILE and AWS_REGION
                    sh "export AWS_PROFILE=${env.ROLE_ACCOUNT}"
                    sh "export AWS_REGION=${params.REGION}"
                    echo "AWS_PROFILE=${env.ROLE_ACCOUNT}, AWS_REGION=${params.REGION}"
                }
            }
        }

        stage('Terragrunt Init') {
            steps {
                script {
                    echo "Initializing Terragrunt..."
                    dir("${env.BASE_DIR}${params.RESOURCE_NAME}") {
                        sh 'terragrunt init'
                    }
                }
            }
        }

        stage('Terragrunt Plan') {
            steps {
                script {
                    echo "Running Terragrunt plan..."
                    dir("${env.BASE_DIR}${params.RESOURCE_NAME}") {
                        sh 'terragrunt plan'
                    }
                }
            }
        }

        stage('Send Approval Email') {
            steps {
                script {
                    emailext (
                        subject: "Approval Required: Terragrunt ${params.ACTION} for ${params.RESOURCE_NAME} in ${params.ENVIRONMENT}",
                        body: """
                            The Terragrunt ${params.ACTION} plan is ready for execution for ${params.RESOURCE_NAME} in the ${params.ENVIRONMENT} environment.
                            Please approve the action to proceed.

                            Environment: ${params.ENVIRONMENT}
                            Region: ${params.REGION}
                            Branch: ${params.BRANCH_NAME}
                            Resource: ${params.RESOURCE_NAME}
                            Action: ${params.ACTION}

                            Click on the following link to view the job: ${env.BUILD_URL}

                            Thank you,
                            Jenkins CI Pipeline
                        """,
                        to: 'approval-team@example.com',
                        replyTo: 'noreply@example.com'
                    )
                    echo "Approval email sent."
                }
            }
        }

        stage('Approval for Terragrunt Apply') {
            steps {
                script {
                    def shouldApply = input message: "Do you want to apply Terragrunt changes to ${params.RESOURCE_NAME} in ${params.ENVIRONMENT} environment?",
                        parameters: [booleanParam(defaultValue: false, description: 'Approve the Terragrunt apply?', name: 'Approve')]

                    if (shouldApply) {
                        echo "Approved. Proceeding with Terragrunt apply."
                    } else {
                        error "Terragrunt apply was not approved."
                    }
                }
            }
        }

        stage('Terragrunt Apply/Destroy') {
            steps {
                script {
                    echo "Executing Terragrunt ${params.ACTION} for ${params.RESOURCE_NAME}..."
                    dir("${env.BASE_DIR}${params.RESOURCE_NAME}") {
                        if (params.ACTION == 'create') {
                            sh 'terragrunt apply -auto-approve'
                        } else if (params.ACTION == 'destroy') {
                            sh 'terragrunt destroy -auto-approve'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment to ${params.ENVIRONMENT} environment for ${params.RESOURCE_NAME} completed successfully."
        }
        failure {
            echo "Deployment failed."
        }
    }
}
