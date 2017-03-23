node('windows') {
	try{
		currentBuild.result = 'SUCCESS'
		stage('Checkout') {
			checkout scm
		}

		stage("Build") {
			//bat 'dir'
			bat 'powershell ".\\vendor-build.ps1"'
		}

		stage("Archive") {
			//archiveArtifacts artifacts: 'build/main*', fingerprint: true, onlyIfSuccessful: true
		}
	} catch(e) {
		currentBuild.result = 'FAILURE'
		slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} ${env.BUILD_NUMBER}' (${env.BUILD_URL})")
		throw e
	} finally {
		step([$class: 'Mailer', notifyEveryUnstableBuild: true, 
			recipients: emailextrecipients([[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']])
		])
	}
}
