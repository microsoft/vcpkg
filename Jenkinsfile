#!/usr/bin/env groovy

branch = 'vcpkg'

node('windows-aws-builder-minimal') {
    ws('C:\\workspace') {
        try {
            checkout(
                [
                    $class: 'GitSCM',
                    branches: scm.branches,
                    extensions: scm.extensions + [[$class: 'WipeWorkspace']],
                    userRemoteConfigs: scm.userRemoteConfigs
                ]
            )

            withMaven (maven: 'default', mavenSettings: 'maven-settings', mavenLocalRepo: '.repository',
            options: [
                artifactsPublisher(disabled: true)
                ]
            ) {
                if (env.BRANCH_NAME =~ /^release\/vcpkg_.+/) {
                    pom = readMavenPom file: 'pom.xml'
                    versionPrefix = pom.getProperties().getProperty('version.prefix')
                    script {
                        currentBuild.displayName = "${versionPrefix}.${BUILD_NUMBER}"
                    }

                    stage ('Tag SCM') {
                        sshagent(['maarcus-teamcity-github-key']) {

                            def repoUrl = scm
                                .getUserRemoteConfigs()[0]
                                .getUrl()

                            bat "git tag ${branch}-${versionPrefix}.${BUILD_NUMBER}"
                            bat "git push ${repoUrl} ${branch}-${versionPrefix}.${BUILD_NUMBER}"
                        }
                    }

                    stage ('Build vcpkg.exe') {
                        bat "bootstrap-vcpkg.bat"
                    }

                    stage ('Build and deploy vcpkg') {
                        bat 'mvn deploy'
                    }
                }
                else {
                    stage ('Build vcpkg.exe') {
                        bat "bootstrap-vcpkg.bat"
                    }

                    stage ('Build vcpkg') {
                        bat 'mvn verify'
                    }
                }
            }
        }
        catch (e) {
            echo 'FAILED: ' + e
            currentBuild.result = 'FAILED'
            throw e
        }
    }
}
