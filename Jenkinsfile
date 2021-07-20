@Library('dst-shared@master') _

//Possible Parameters Include
// * executeScript         Name of script which creates .tar file
// * executeScript2        Name of script which creates CLI .md files
// * dockerfile            Path to the Docker file relative to the repository root.  Default Dockerfile
// * dockerBuildContextDir The build context directory for Docker builds.  Default to '.' i.e. workspace root
// * dockerArguments       Additional arguments to pass to the build of the Docker application
// * dockerBuildTarget     Target to build when building the Docker application. Defaults to unset
// * masterBranch          Branch to consider as master, only this branch will receive the latest tag.  Default master
// * repository            Docker repository name to use
// * imagePrefix           Docker image name prefix
// * name                  Name of the Docker image used to add metadata to the image
// * description           Description of the Docker image used to add metadata to the image
// * slackNotification     Array: ["<slack_channel>", "<jenkins_credential_id", <notify_on_start>, <notify_on_success>, <notify_on_failure>, <notify_on_fixed>]]
// * product               String: set product for the transfer function
// * targetOS              String: set targetOS for the transfer function

// Jenkins library for building docker files
// Copyright 2019 - 2021 Hewlett Packard Enterprise Development, LP


def pipelineParams= [
    makeMakefile: "portal/developer-portal/Makefile",
    dockerfileSpell: "Dockerfile.spellcheck",
    repository: "cray",
    imagePrefix: "sat-docs",
    name: "sat-docs",
    description: "Docs-as-code template",
    masterBranch: 'master',
    dockerBuildContextDir: '.',
    dockerArguments: "",
    dockerBuildTarget: "application",
    useEntryPointForTest: true,
    slackNotification: ["", "", true, true, true, true],
    product: "pubs",
    targetOS: "noos",
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
        VERSION = sh(returnStdout: true, script: "./setup_versioning.sh;cat .version").trim()
        VERSION_RPM = "${VERSION}" 
        GIT_TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
        BUILD_DATE = "${buildDate}"
        IMAGE_TAG = getDockerImageTag(version: "${VERSION}", buildDate: "${BUILD_DATE}", gitTag: "${GIT_TAG}")
        IMAGE_NAME_PDFHTML = "${pipelineParams.imagePrefix}-pdfhtml-${IMAGE_TAG}"
        IMAGE_NAME_PDF = "${pipelineParams.imagePrefix}-pdf-${IMAGE_TAG}"
        IMAGE_NAME_HTML = "${pipelineParams.imagePrefix}-html-${IMAGE_TAG}"
        PRODUCT = "${pipelineParams.product}"
        TARGET_OS = "${pipelineParams.targetOS}"
        TARGET_ARCH = "noarch"
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
        stage('Workdir Preparation') {
            steps {
                sh "mkdir -p build"
                echo "image tag for this build is ${IMAGE_TAG}"
            }
        }
        
        /*
        stage('Spellcheck') {
            steps {
                sh """
                    docker build -t basecontainer-${containerId_toss} --target build -f ${pipelineParams.dockerfileSpell} .
                """
            }
        }
        */

        stage('Build PDF HTML') {
            environment {
                BUILD_DATE = "${buildDate}"
            }
            steps {
            // Build PDF HTML
            echo "${BUILD_DATE}"
            sh """
                if [[ -f ${pipelineParams.makeMakefile} ]]; then
                    mkdir -p ${WORKSPACE}/build/results
                    cd portal/developer-portal;make tar
                    cp build/*.tar ${WORKSPACE}/build/results/${IMAGE_NAME_PDFHTML}.tar
                    cp build/pdf ${WORKSPACE}/build/results/${IMAGE_NAME_PDF} -rf
                    cp build/html ${WORKSPACE}/build/results/${IMAGE_NAME_HTML} -rf
                else
                    echo "${pipelineParams.makeMakefile} doesn't exist"
                    exit 1
                fi
                """

            }
        }

        /* 
        stage('Create RPM') {
            environment {
                VERSION = "${env.VERSION_RPM}"
            }
            steps {
            sh """
                if [[ -f ${pipelineParams.makeMakefile} ]]; then
                    ls -latr ${WORKSPACE}/build/results
                    cd portal/developer-portal;
                    cp  ${WORKSPACE}/build/results/${IMAGE_NAME_PDF} pdf -rf
                    cp  ${WORKSPACE}/build/results/${IMAGE_NAME_HTML} html -rf
                    make package
                    cp -r rpmbuild/RPMS/x86_64/*.rpm ${WORKSPACE}/build/results
                else
                    echo "${pipelineParams.makeMakefile} doesn't exist"
                    exit 1
                fi
                """
            }
        }
        */
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

