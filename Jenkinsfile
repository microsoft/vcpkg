node('windows') {
	catchError {
		stage('Checkout') {
			checkout scm
		}

		stage("Build") {
			bat 'powershell ".\\vendor-build.ps1"'
		}

		stage("Archive") {
			bat 'del vcpkg.zip'
			bat 'cmake -E tar cf vcpkg.zip installed scripts --format=zip'
			//zip zipFile: 'vcpkg.zip', dir: '', glob: 'installed/**,scripts/**'
			archiveArtifacts artifacts: 'vcpkg.zip', fingerprint: true, onlyIfSuccessful: true
		}
	}
	step([$class: 'Mailer', notifyEveryUnstableBuild: true, 
		recipients: emailextrecipients([[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']])
	])
}
