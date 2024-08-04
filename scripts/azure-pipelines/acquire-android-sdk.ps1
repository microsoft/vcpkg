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
& bash -c 'yes | ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$ANDROID_HOME" --licenses'
& ./android-sdk/cmdline-tools/bin/sdkmanager "--sdk_root=$env:ANDROID_HOME" --list_installed
