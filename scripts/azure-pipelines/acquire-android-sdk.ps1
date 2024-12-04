# OpenLogic provides OpenJDK builds under liberal terms 💚
# https://www.openlogic.com/openjdk-downloads
$JDKVersion = '11.0.25+9' # max for allegro5, but not enough for sdkmanager
$JREVersion = '17.0.13+11' # for sdkmanager
$ToolsVersion = '10406996_latest'

Write-Host "Downloading the Android SDK"
& "./vcpkg" x-download sdk-commandlinetools-linux-$ToolsVersion.zip "--sha512=64b7d18ee7adeb1204eaa2978091e874dc9af9604796b64e1a185a11c15325657383fc9900e55e4590c8b8a2784b3881745d2f32daef1207e746c0ee41c2b72b" "--url=https://dl.google.com/android/repository/commandlinetools-linux-${ToolsVersion}.zip"

$env:ANDROID_HOME = Join-Path $Pwd "android-sdk"
Write-Host "Setting up the Android SDK in $env:ANDROID_HOME"
& unzip -q sdk-commandlinetools-linux-$ToolsVersion.zip -d android-sdk

# https://doc.qt.io/qt-6/android-getting-started.html
if ($false) {
    & bash -c 'yes | ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0"'
} else {
    $filename = 'build-tools_r34-linux.zip'
    Write-Host "Adding $filename"
    & "./vcpkg" x-download $filename "--sha512=c28dd52f8eca82996726905617f3cb4b0f0aee1334417b450d296991d7112cab1288f5fd42c48a079ba6788218079f81caa3e3e9108e4a6f27163a1eb7f32bd7" "--url=https://dl.google.com/android/repository/$filename"
    New-Item -Name android-sdk/build-tools -Type Directory
    & unzip -q $filename -d android-sdk/build-tools
    Rename-Item ./android-sdk/build-tools/android-14 34.0.0

    $filename = 'platform-34-ext7_r03.zip'
    Write-Host "Adding $filename"
    & "./vcpkg" x-download $filename "--sha512=7d7feb2b04326578cc37fd80e9a8b604aa8bcd8360de160eadedf2a5f28f62a809d3bd6e386d72ba9d32cacbf0a0e3417d54c4195d5091d86d40b29404b222bb" "--url=https://dl.google.com/android/repository/$filename"
    New-Item -Name android-sdk/platforms -Type Directory
    & unzip -q $filename -d android-sdk/platforms

    $filename = 'platform-tools_r35.0.1-linux.zip'
    Write-Host "Adding $filename"
    & "./vcpkg" x-download $filename "--sha512=6b95e496cbef1e0940aaca79ab7c3f149f8e670a1fd427fdc34ee22cac773aaa1b5619a4e964d0c176894fb6fb9ecb9d3a037a657c086aa737a2c104f9a1f229" "--url=https://dl.google.com/android/repository/$filename"
    & unzip -q $filename -d android-sdk
}

Write-Host "Downloading the JRE"
$JREFile = "openlogic-openjdk-jre-$JREVersion-linux-x64.tar.gz"
$JREUrl = "https://builds.openlogic.com/downloadJDK/openlogic-openjdk-jre/$JREVersion/$JREFile"
& "./vcpkg" x-download $JREFile "--sha512=5ef4d02923e24875d80a920a3c1c55b45f958f579c38bffe42bd02afc67ea16c3f67bcbe994bbce72fd98584485ef108d7aec8a2e90fc4df9402e0201420eb10" "--url=$JREUrl" @cachingArgs

$env:JAVA_HOME = Join-Path $Pwd "openlogic-openjdk-jre-$JREVersion-linux-x64"
Write-Host "Setting up the JRE in $env:JAVA_HOME"
& tar -xzf $JREFile

Write-Host "Completing SDK setup"
& bash -c 'yes | ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$ANDROID_HOME" --licenses'
& ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$env:ANDROID_HOME" --list_installed

Write-Host "Downloading the JDK"
$JDKFile = "openlogic-openjdk-$JDKVersion-linux-x64.tar.gz"
$JDKUrl = "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/$JDKVersion/$JDKFile"
& "./vcpkg" x-download $JDKFile "--sha512=e4991553adb987003f8fa61e7b6126bd6af2da5a379c7aa67473a1c5df2d9d9809518e29e9a1ce2ea7cf7d7376fb9b17e2a7ef935973a073429cb43b709a6d0c" "--url=$JDKUrl" @cachingArgs

$env:JAVA_HOME = Join-Path $Pwd "openlogic-openjdk-$JDKVersion-linux-x64"
Write-Host "Setting up the JDK in $env:JAVA_HOME"
& tar -xzf $JDKFile
