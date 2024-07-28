$JDKVersion = '17.0.2'
$ToolsVersion = '10406996_latest'

Write-Host "Downloading the JDK"
& "./vcpkg" x-download openjdk-$JDKVersion.tar.gz "--sha512=0bf168239a9a1738ad6368b8f931d072aeb122863ec39ea86dc0449837f06953ce18be87bab7e20fd2585299a680ea844ec419fa235da87dfdd7e37b73740a57" "--url=https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-${JDKVersion}_linux-x64_bin.tar.gz" @cachingArgs

Write-Host "Setting up the JDK in $env:JAVA_HOME"
$env:JAVA_HOME = Join-Path $Pwd "jdk-$JDKVersion"
& tar -xvf openjdk-$JDKVersion.tar.gz

Write-Host "Downloading the Android SDK"
& "./vcpkg" x-download sdk-commandlinetools-linux-$ToolsVersion.zip "--sha512=64b7d18ee7adeb1204eaa2978091e874dc9af9604796b64e1a185a11c15325657383fc9900e55e4590c8b8a2784b3881745d2f32daef1207e746c0ee41c2b72b" "--url=https://dl.google.com/android/repository/commandlinetools-linux-${ToolsVersion}.zip"

$env:ANDROID_HOME = Join-Path $Pwd "android-sdk"
Write-Host "Setting up the Android SDK in $env:ANDROID_HOME"
& unzip -q sdk-commandlinetools-linux-$ToolsVersion.zip -d android-sdk
# https://doc.qt.io/qt-6/android-getting-started.html
& bash -c 'yes | ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0"'
& ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$env:ANDROID_HOME" --list_installed
