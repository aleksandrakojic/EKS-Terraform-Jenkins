properties([
  parameters([
    string(name: 'CLUSTER_NAME', defaultValue: ''),
    string(name: 'AWS_REGION', defaultValue: ''),
    string(name: 'WORKER_NODE_COUNT', defaultValue: ''),
    string(name: 'WORKER_NODE_SIZE', defaultValue: 't3.medium'),
    string(name: 'ACTION', defaultValue: 'apply', description: 'Action to perform (apply or destroy)')
  ]),
  pipelineTriggers([])
])

// Environment Variables
env.region = AWS_REGION
env.cluster_name = CLUSTER_NAME
env.instance_count = WORKER_NODE_COUNT
env.instance_size = WORKER_NODE_SIZE

pipeline {

  environment {
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  }

  agent any

  stages {
        // Git Checkout stage
    stage('Git Checkout'){
      steps{
        git branch: 'main', credentialsId: 'cred', url: 'https://github.com/aleksandrakojic/EKS-Terraform-Jenkins'
      }
    }
    
    // Terraform Destroy stage
    stage('Terraform Destroy') {
        when {
            expression { params.ACTION == 'destroy' }
        }
        steps {
            echo '** WARNING: Destroying infrastructure. Ensure proper backups and approvals. **'
            sh "export TF_VAR_region='${env.region}' && export TF_VAR_cluster_name='${env.cluster_name}' && export TF_VAR_instance_count='${env.instance_count}' && export TF_VAR_instance_size='${env.instance_size}' && terraform destroy -auto-approve"
        }
    }

    // Terraform Init stage
    stage('Terraform Init'){
        steps{
            sh "export TF_VAR_region='${env.region}' && export TF_VAR_cluster_name='${env.cluster_name}' && export TF_VAR_instance_count='${env.instance_count}' && export TF_VAR_instance_size='${env.instance_size}' && terraform init"
        }
    }

    // Terraform Plan stage
    stage('Terraform Plan'){
        steps{
            sh "export TF_VAR_region='${env.region}' && export TF_VAR_cluster_name='${env.cluster_name}' && export TF_VAR_instance_count='${env.instance_count}' && export TF_VAR_instance_size='${env.instance_size}' && terraform plan"
        }
    }

    // Approval stage (for apply action)
    stage('Approval (apply only)') {
        when {
            expression { params.ACTION == 'apply' }
        }
        steps {
            script {
            def userInput = input(id: 'ConfirmApply', message: 'Apply Terraform changes?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply Terraform', name: 'ConfirmApply'] ])
            if (!userInput) {
                error 'Terraform apply cancelled by user.'
            }
            }
        }
    }

    // Terraform Apply stage
    stage('Terraform Apply') {
        when {
            expression { params.ACTION == 'apply' }
        }
        steps {
            sh "export TF_VAR_region='${env.region}' && export TF_VAR_cluster_name='${env.cluster_name}' && export TF_VAR_instance_count='${env.instance_count}' && export TF_VAR_instance_size='${env.instance_size}' && terraform apply -auto-approve"
        }
    }

    // Update EKS kubeconfig stage
    stage('Update EKS kubeconfig') {
        when {
            expression { params.ACTION == 'apply' }
        }
        steps {
            sh "aws eks update-kubeconfig --region ${env.region} --name ${env.cluster_name}"
        }
    }
}
}
