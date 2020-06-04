#!/usr/bin/groovy
library 'adminsLib@master'

properties([
    parameters([
        string(defaultValue: '', description: 'plugin id from https://grafana.com/grafana/plugins', name: 'PLUGIN_NAME', trim: false),
        string(defaultValue: '', description: 'plugin version', name: 'PLUGIN_VERSION', trim: false),
        string(defaultValue: '', description: 'deb-drop repository, see https://github.com/innogames/deb-drop/', name: 'REPO_NAME', trim: false),
    ])
])

// Remove builds in presented status, default is ['ABORTED', 'NOT_BUILT']
jobCommon.cleanNotFinishedBuilds()

node('docker') {
ansiColor('xterm') {
    // Checkout repo and get info about current stage
    sh 'echo Initial env; env | sort'
    env.PACKAGE_NAME = 'graphite-ch-optimizer'
    try {
        stage('Checkout') {
            gitSteps checkout: true, changeBuildName: false
            sh 'set +x; echo "Environment variables after checkout:"; env|sort'
            currentBuild.displayName = "${currentBuild.number}: ${env.PLUGIN_NAME} version ${env.PLUGIN_VERSION}"
        }
        stage('Upload to deb-drop') {
            when(env.REPO_NAME != '' && env.PLUGIN_NAME != '' && env.PLUGIN_VERSION != '') {
                sh 'set -ex; make clean "${PLUGIN_NAME}:${PLUGIN_VERSION}" PACKAGES=deb'
                withCredentials([string(credentialsId: 'DEB_DROP_TOKEN', variable: 'DebDropToken')]) {
                    jobCommon.uploadPackage  file: "grafana-plugin-${env.PLUGIN_NAME}_${env.PLUGIN_VERSION}_amd64.deb", repo: env.REPO_NAME, token: DebDropToken
                }
            }
        }
        cleanWs(notFailBuild: true)
    }
    catch (all) {
        currentBuild.result = 'FAILURE'
        error "Something wrong, exception is: ${all}"
        jobCommon.processException(all)
    }
    finally {
        jobCommon.postSlack()
    }
}
}
