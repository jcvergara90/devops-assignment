#!groovy



def update_service(def config) {
  withEnv(config) {
    push_aws_ecr(config)
    sh 'make aws.ecs.update.service'
  }
}

def stack_infra(def config) {
  withEnv(config) {
    sh 'make aws.ecr.create.repository'
    sh 'make aws.sm.create.secret'
    push_aws_ecr(config)
    sh 'make aws.stack.deploy'
    sh 'make aws.stack.deploy.autoscaling'
  }
}

return this
