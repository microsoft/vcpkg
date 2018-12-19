node('work-server') {
	try {
		notify('warning', "STARTED")
		
		stage ("Clean Workspace") {
			deleteDir()
		}
			
		stage ("Clone Thirdparty Sources") {
			checkout scm
		}
		
		withMaven (maven: "default", mavenSettings: "maven-settings") {
			if (env.BRANCH_NAME == 'master') {
				pom = readMavenPom file: 'pom.xml'
				versionPrefix = pom.getProperties().getProperty('versionPrefix')
				script {
					currentBuild.displayName = "${versionPrefix}.${BUILD_NUMBER}"
				}

				stage ("Set versions") {
					bat "mvn clean versions:set -DnewVersion=${versionPrefix}"
				}

				stage ("Deploy") {
					bat "mvn clean deploy -Dbuild.path=\"C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/15.0/Bin/\""
				}
			}
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