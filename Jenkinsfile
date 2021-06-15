@Library('dst-shared@master') _

// Possible Parameters:
// * makefile              Path to the makefile that compiles the documentation
// * repo                  The name of the repository, used as the prefix for the RPM and tar archive
// * slackNotification     Array: ["<slack_channel>", "<jenkins_credential_id>", <notify_on_start>, <notify_on_success>, <notify_on_failure>, <notify_on_fixed>]]
// * targetOS              Used when transferring to artifactory
// * targetArch            Used when transferring to artifactory

// Jenkinsfile for building documentation
// Copyright 2021 Hewlett Packard Enterprise Development LP.


def pipelineParams = [
    makefile: "portal/developer-portal/Makefile",
    repo: "sat-docs",
    slackNotification: ["", "", false, false, true, true],
    targetOS: 'noos',
    targetArch: 'noarch'
]

// Build date
def buildDate = new Date().format( 'yyyyMMddHHmmss' )

// UUID distinquishes base containers
def containerId_sq = UUID.randomUUID().toString()

// Container Used for spellcheck.
def containerId_toss = UUID.randomUUID().toString()

// Variable to check whether to skip the 'success' post section
def skipSuccess = false

// Variable to decide whether to skip the slackNotify steps if the plugin isn't installed
def skipSlack = slackNotify(exceptionCatch: true)

// Slack notification of starting the Jenkins job if enabled
if ((pipelineParams.slackNotification[2] != false && skipSlack != true)) {
    slackNotify(channel: "${pipelineParams.slackNotification[0]}", credential: "${pipelineParams.slackNotification[1]}", color: "good", message: "Starting: ${env.JOB_NAME} | Build URL: ${env.BUILD_URL}")
}

// Set cron to build nightly for master or release, not other branches
def relpattern = /release/
String cron_str = BRANCH_NAME == "master" || BRANCH_NAME ==~ relpattern ? "H H(0-7) * * *" : ""

pipeline {
    agent { node { label 'dstbuild' } }

    triggers { cron(cron_str) }

    // Configuration options applicable to the entire job
    options {
        // This build should not take long, fail the build if it appears stuck
        timeout(time: 45, unit: 'MINUTES')

        // Don't fill up the build server with unnecessary cruft
        buildDiscarder(logRotator(numToKeepStr: '10'))

        // Add timestamps and color to console output, cuz pretty
        timestamps()
    }
    environment {
        VERSION = sh(returnStdout: true, script: "cat .version").trim()
        GIT_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
        BUILD_DATE = "${buildDate}" 
        IMAGE_TAG = getDockerImageTag(version: "${VERSION}", buildDate: "${BUILD_DATE}", gitTag: "${GIT_TAG}")
        IMAGE_NAME = "${pipelineParams.repo}-directory-${IMAGE_TAG}"
        IMAGE_NAME_PDFHTML = "${pipelineParams.repo}-pdfhtml-${IMAGE_TAG}"
        IMAGE_NAME_PDF = "${pipelineParams.repo}-pdf-${IMAGE_TAG}"
        TARGET_OS = "${pipelineParams.targetOS}"
        TARGET_ARCH = "${pipelineParams.targetArch}"
    }
    stages {
        // For debugging
        stage('Print Build Info') {
            steps {
                printBuildInfo(pipelineParams)
                script {
                        echo "Print all Environment Variables"
                        sh "env | sort"
                    }
            }
        }
        stage('Spellcheck') {
            // Skip 'make spellcheck' which requires pandoc
            // TODO: run in docker
            when { expression { false }}
            steps {
                dir("portal/developer-portal"){
                    sh "make spellcheck"
                }
            }
        }
        stage('Build PDF HTML') {
            environment {
                BUILD_DATE = "${buildDate}" 
            }
            steps {
                echo "${BUILD_DATE}"
                sh """
                    if [[ -f ${pipelineParams.makefile} ]]; then
                        mkdir -p ${WORKSPACE}/build/results
                        cd portal/developer-portal; make lint && make tar
                        cp docs/*.tar ${WORKSPACE}/build/results/${IMAGE_NAME_PDFHTML}.tar
                        cp docs/pdf ${WORKSPACE}/build/results/${IMAGE_NAME_PDF} -rf
                    else
                        echo "${pipelineParams.makefile} doesn't exist"
                        exit 1
                    fi
                    """
                }
        }
        stage('Create RPM') {
            // Skip building RPM temporarily
            // TODO: get RPM build working
            when { expression { false }}
            steps {
            sh """
                if [[ -f ${pipelineParams.makefile} ]]; then
                    ls -latr ${WORKSPACE}/build/results
                    cd portal/developer-portal;    
                    cp  ${WORKSPACE}/build/results/${IMAGE_NAME_PDF} pdf -rf
                    make package
                    cp -r rpmbuild/RPMS/x86_64/*.rpm ${WORKSPACE}/build/results
                else
                    echo "${pipelineParams.makefile} doesn't exist"
                    exit 1
                fi
                """
            }
        }
        stage('Transfer') {
            steps {
                script {
                    if ( checkFileExists(filePath: 'build/results/*.tar') ) {
                        transfer(artifactName: "build/results/*.tar")
                    }
                    if ( checkFileExists(filePath: 'build/results/*.rpm') ) {
                        transfer(artifactName: "build/results/*.rpm")
                    }
                }
            }
        }
    }
    post('Post-build steps') {
        always {
            script {
                currentBuild.result = currentBuild.result == null ? "SUCCESS" : currentBuild.result
            }
            //findAndTransferArtifacts()
            logstashSend failBuild: false, maxLines: 3000
        }
        fixed {
            notifyBuildResult(headline: "FIXED")
            script {
                if ((pipelineParams.slackNotification[5] != false && skipSlack != true)) {
                    // Manually set the status to "FIXED" because it's not one of the accepted inputs for currentBuild.result
                    slackNotify(channel: "${pipelineParams.slackNotification[0]}", credential: "${pipelineParams.slackNotification[1]}", color: "good", message: "Finished: ${env.JOB_NAME} | Build URL: ${env.BUILD_URL} | Status: FIXED")
                }
                // Set to true so the 'success' post section is skipped when the build result is 'fixed'
                // Otherwise both 'fixed' and 'success' sections will execute due to Jenkins behavior
                skipSuccess = true
            }
        }
        failure {
            notifyBuildResult(headline: "FAILED")
            script {
                if ((pipelineParams.slackNotification[4] != false && skipSlack != true)) {
                    slackNotify(channel: "${pipelineParams.slackNotification[0]}", credential: "${pipelineParams.slackNotification[1]}", color: "danger", message: "Finished: ${env.JOB_NAME} | Build URL: ${env.BUILD_URL} | Status: ${currentBuild.result}")
                }
            }
        }
        success {
            script {
                if ((pipelineParams.slackNotification[3] != false && skipSlack != true && skipSuccess != true)) {
                    // Have to manually set the currentBuild.result var to 'SUCCESS' when the job is successful, otherwise it appears as 'null'
                    currentBuild.result = 'SUCCESS'
                    slackNotify(channel: "${pipelineParams.slackNotification[0]}", credential: "${pipelineParams.slackNotification[1]}", color: "good", message: "Finished: ${env.JOB_NAME} | Build URL: ${env.BUILD_URL} | Status: ${currentBuild.result}")
                }
            }
        }
    }
}

