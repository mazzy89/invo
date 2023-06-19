podTemplate(yaml: '''
              kind: Pod
              spec:
                containers:
                - name: kaniko
                  image: gcr.io/kaniko-project/executor:v1.11.0-debug
                  imagePullPolicy: Always
                  command:
                  - sleep
                  args:
                  - 99d
                  volumeMounts:
                    - name: jenkins-docker-cfg
                      mountPath: /kaniko/.docker
                volumes:
                - name: jenkins-docker-cfg
                  projected:
                    sources:
                    - secret:
                        name: dockercred
                        items:
                          - key: .dockerconfigjson
                            path: config.json
'''
  ) {

  node(POD_LABEL) {
    stages {
      stage("Checkout") {
        checkout scm
      }

      stage("Prepare repo") {
        sh "cp -r `pwd`/docker/${params.invo_version}/. `pwd`"
      }

      stage("Build and Push") {
        container('kaniko') {
          sh "/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true --destination=${params.docker_image}:${params.git_tag}"
        }
      }
    }
  }
}
