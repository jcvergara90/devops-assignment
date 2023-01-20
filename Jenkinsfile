def fnSteps = evaluate readTrusted("deploy/steps.groovy")

pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'pre', 'prod', 'pre1a'],
            description: 'Ambiente donde se va a desplegar')
        choice(
            name: 'EXECUTE',
            choices: [ 'UPDATE_SERVICE', 'DEPLOY_INFRA' ],
            description: 'Tarea a realizar')
    }
    stages {
        stage('Deploy Infra') {
            when { expression { return params.EXECUTE == 'DEPLOY_INFRA' }}
            steps { script { fnSteps.stack_deploy(config) }}
        }
        stage('Update service') {
            when { expression { return params.EXECUTE == 'UPDATE_SERVICE' }}
            steps { script { fnSteps.update_service(config) }}
        }
    }
    post {
        always { cleanWs() }
    }
}
