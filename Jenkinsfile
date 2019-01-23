node('work-server') {
	try {
		notify('warning', "STARTED")
			
		stage ("Clone vcpkg") {
			checkout scm
		}
		
		withMaven (maven: "default", mavenSettings: "maven-settings", mavenLocalRepo: ".repository", 
			options: [
				artifactsPublisher(disabled: true)
				]
			) {
			if (env.BRANCH_NAME == 'master') {
				pom = readMavenPom file: 'pom.xml'
				versionPrefix = pom.getProperties().getProperty('version.prefix')
				script {
					currentBuild.displayName = "${versionPrefix}-${BUILD_NUMBER}"
				}

				stage ("Set versions") {
					bat "mvn versions:set -DnewVersion=${versionPrefix}"
				}

				stage ("Deploy vcpkg") {
					bat "mvn clean deploy"
				}
			}
		}
		
		stage ("Clean workspace") {
			deleteDir()
		}

		notify('good', 'SUCCESS')
		
	} catch (e) {
		currentBuild.result = "FAILED"
		notify('danger', 'FAILED')
		throw e
	}
}

def notify(color, message) {
    withCredentials([string(credentialsId: 'work-server-slack', variable: 'TOKEN')]) {
        slackSend(
            channel: '#build-notifications',
            color: color,
            message: message + ": Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
            teamDomain: 'work-server',
            token: "$TOKEN"
        )
    }
}