#!/bin/sh

# Find .vcpkg-root, which indicates the root of this repo
vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
while [ "$vcpkgRootDir" != "/" ] && ! [ -e "$vcpkgRootDir/.vcpkg-root" ]; do
    vcpkgRootDir="$(dirname "$vcpkgRootDir")"
done

# Argument parsing
vcpkgDisableMetrics="OFF"
vcpkgUseSystem=false
vcpkgAllowAppleClang=false
vcpkgBuildTests="OFF"
for var in "$@"
do
    if [ "$var" = "-disableMetrics" -o "$var" = "--disableMetrics" ]; then
        vcpkgDisableMetrics="ON"
    elif [ "$var" = "-useSystemBinaries" -o "$var" = "--useSystemBinaries" ]; then
        vcpkgUseSystem=true
    elif [ "$var" = "-allowAppleClang" -o "$var" = "--allowAppleClang" ]; then
        vcpkgAllowAppleClang=true
    elif [ "$var" = "-buildTests" ]; then
        vcpkgBuildTests="ON"
    elif [ "$var" = "-help" -o "$var" = "--help" ]; then
        echo "Usage: ./bootstrap-vcpkg.sh [options]"
        echo
        echo "Options:"
        echo "    -help                Display usage help"
        echo "    -disableMetrics      Do not build metrics reporting into the executable"
        echo "    -useSystemBinaries   Force use of the system utilities for building vcpkg"
        echo "    -allowAppleClang     Set VCPKG_ALLOW_APPLE_CLANG to build vcpkg in apple with clang anyway"
        exit 1
    else
        echo "Unknown argument $var. Use '-help' for help."
        exit 1
    fi
done

# Enable using this entry point on windows from git bash by redirecting to the .bat file.
unixName=$(uname -s | sed 's/MINGW.*_NT.*/MINGW_NT/')
if [ "$unixName" = "MINGW_NT" ]; then
    if [ "$vcpkgDisableMetrics" = "ON" ]; then
        args="-disableMetrics"
    else
        args=""
    fi

    vcpkgRootDir=$(cygpath -aw "$vcpkgRootDir")
    cmd "/C $vcpkgRootDir\\bootstrap-vcpkg.bat $args" || exit 1
    exit 0
fi

if [ -z ${VCPKG_DOWNLOADS+x} ]; then
    downloadsDir="$vcpkgRootDir/downloads"
else
    downloadsDir="$VCPKG_DOWNLOADS"
    if [ ! -d "$VCPKG_DOWNLOADS" ]; then
        echo "VCPKG_DOWNLOADS was set to '$VCPKG_DOWNLOADS', but that was not a directory."
        exit 1
    fi

fi

extractStringBetweenDelimiters()
{
    input=$1;leftDelim=$2;rightDelim=$3
    output="${input##*$leftDelim}"
    output="${output%%$rightDelim*}"
    echo "$output"
}

vcpkgCheckRepoTool()
{
    __tool=$1
    if ! command -v "$__tool" >/dev/null 2>&1 ; then
        echo "Could not find $__tool. Please install it (and other dependencies) with:"
        echo "sudo apt-get install curl zip unzip tar"
        exit 1
    fi
}

vcpkgCheckBuildTool()
{
    __tool=$1
    if ! command -v "$__tool" >/dev/null 2>&1 ; then
	echo "Could not find $__tool. Please install it (and other dependencies) with:"
	echo "sudo apt-get install cmake ninja-build"
	exit 1
    fi
}

vcpkgCheckEqualFileHash()
{
    url=$1; filePath=$2; expectedHash=$3

    if command -v "sha512sum" >/dev/null 2>&1 ; then
        actualHash=$(sha512sum "$filePath")
    else
        # sha512sum is not available by default on osx
        # shasum is not available by default on Fedora
        actualHash=$(shasum -a 512 "$filePath")
    fi

    actualHash="${actualHash%% *}" # shasum returns [hash filename], so get the first word

    if ! [ "$expectedHash" = "$actualHash" ]; then
        echo ""
        echo "File does not have expected hash:"
        echo "              url: [ $url ]"
        echo "        File path: [ $downloadPath ]"
        echo "    Expected hash: [ $sha512 ]"
        echo "      Actual hash: [ $actualHash ]"
        exit 1
    fi
}

vcpkgDownloadFile()
{
    url=$1; downloadPath=$2 sha512=$3
    vcpkgCheckRepoTool "curl"
    rm -rf "$downloadPath.part"
    curl -L $url --tlsv1.2 --create-dirs --retry 3 --output "$downloadPath.part" --silent --show-error --fail || exit 1

    vcpkgCheckEqualFileHash $url "$downloadPath.part" $sha512
    mv "$downloadPath.part" "$downloadPath"
}

vcpkgExtractArchive()
{
    archive=$1; toPath=$2
    rm -rf "$toPath" "$toPath.partial"
    mkdir -p "$toPath.partial"

    archiveType="${archive##*.}"
    if [ "$archiveType" = "zip" ]; then
        vcpkgCheckRepoTool "unzip"
        $(cd "$toPath.partial" && unzip -qqo "$archive")
    else
        vcpkgCheckRepoTool "tar"
        $(cd "$toPath.partial" && tar xzf "$archive")
    fi
    mv "$toPath.partial" "$toPath"
}

fetchTool()
{
    tool=$1; UNAME=$2; __output=$3

    if [ "$tool" = "" ]; then
        echo "No tool name provided"
        return 1
    fi

    if [ "$UNAME" = "Linux" ]; then
        os="linux"
    elif [ "$UNAME" = "Darwin" ]; then
        os="osx"
    elif [ "$UNAME" = "FreeBSD" ]; then
        os="freebsd"
    else
        echo "Unknown uname: $UNAME"
        return 1
    fi

    xmlFileAsString=`cat "$vcpkgRootDir/scripts/vcpkgTools.xml"`
    toolRegexStart="<tool name=\"$tool\" os=\"$os\">"
    toolData="$(extractStringBetweenDelimiters "$xmlFileAsString" "$toolRegexStart" "</tool>")"
    case "$toolData" in
	"" | "<!xml"*)
        echo "No entry for $toolRegexStart in $vcpkgRootDir/scripts/vcpkgTools.xml"
        return 1
    esac

    version="$(extractStringBetweenDelimiters "$toolData" "<version>" "</version>")"

    toolPath="$downloadsDir/tools/$tool-$version-$os"

    exeRelativePath="$(extractStringBetweenDelimiters "$toolData" "<exeRelativePath>" "</exeRelativePath>")"
    exePath="$toolPath/$exeRelativePath"

    if [ -e "$exePath" ]; then
        eval $__output="'$exePath'"
        return 0
    fi

    isArchive=true
    if [ $isArchive = true ]; then
        archiveName="$(extractStringBetweenDelimiters "$toolData" "<archiveName>" "</archiveName>")"
        downloadPath="$downloadsDir/$archiveName"
    else
        echo "Non-archives not supported yet"
        return 1
    fi

    url="$(extractStringBetweenDelimiters "$toolData" "<url>" "</url>")"
    sha512="$(extractStringBetweenDelimiters "$toolData" "<sha512>" "</sha512>")"
    if ! [ -e "$downloadPath" ]; then
        echo "Downloading $tool..."
        vcpkgDownloadFile $url "$downloadPath" $sha512
        echo "Downloading $tool... done."
    else
        vcpkgCheckEqualFileHash $url "$downloadPath" $sha512
    fi

    if [ $isArchive = true ]; then
        echo "Extracting $tool..."
        vcpkgExtractArchive "$downloadPath" "$toolPath"
        echo "Extracting $tool... done."
    fi

    if ! [ -e "$exePath" ]; then
        echo "Could not detect or download $tool"
        return 1
    fi

    eval $__output="'$exePath'"
    return 0
}

selectCXX()
{
    if [ "x$CXX" = "x" ]; then
        if which g++-11 >/dev/null 2>&1; then
            CXX=g++-11
        elif which g++-10 >/dev/null 2>&1; then
            CXX=g++-10
        elif which g++-9 >/dev/null 2>&1; then
            CXX=g++-9
        elif which g++-8 >/dev/null 2>&1; then
            CXX=g++-8
        elif which g++-7 >/dev/null 2>&1; then
            CXX=g++-7
        elif which g++-6 >/dev/null 2>&1; then
            CXX=g++-6
        elif which g++ >/dev/null 2>&1; then
            CXX=g++
        fi
        # If we can't find g++, allow CMake to do the look-up
    fi
}

# Preparation
UNAME="$(uname)"
ARCH="$(uname -m)"

# Force using system utilities for building vcpkg if host arch is arm, arm64, s390x, or ppc64le.
if [ "$ARCH" = "armv7l" -o "$ARCH" = "aarch64" -o "$ARCH" = "s390x" -o "$ARCH" = "ppc64le" ]; then
    vcpkgUseSystem=true
fi

if [ "$UNAME" = "OpenBSD" ]; then
    vcpkgUseSystem=true

    if [ -z "$CXX" ]; then
        CXX=/usr/bin/clang++
    fi
    if [ -z "$CC" ]; then
        CC=/usr/bin/clang
    fi
fi

if $vcpkgUseSystem; then
    cmakeExe="cmake"
    ninjaExe="ninja"
    vcpkgCheckBuildTool "$cmakeExe"
    vcpkgCheckBuildTool "$ninjaExe"
else
    fetchTool "cmake" "$UNAME" cmakeExe || exit 1
    fetchTool "ninja" "$UNAME" ninjaExe || exit 1
fi
if [ "$os" = "osx" ]; then
    if [ "$vcpkgAllowAppleClang" = "true" ] || [[ $(sw_vers -productVersion | awk -F '.' '{print $1}') -ge 11 ]]; then
        CXX=clang++
    else
        selectCXX
    fi
else
    selectCXX
fi

# Do the build
vcpkgToolReleaseTag="2021-09-10"
vcpkgToolReleaseSha="0bea4c7bdd91933d44a0214e2202eb5ef988826d32ae7a00a8868e510710e7de0b336b1cc6aa1ea20af2f6e24d92f2ab665046089bb4ec43bc2add94a901d5fc"
vcpkgToolReleaseTarball="$vcpkgToolReleaseTag.tar.gz"
vcpkgToolUrl="https://github.com/microsoft/vcpkg-tool/archive/$vcpkgToolReleaseTarball"
baseBuildDir="$vcpkgRootDir/buildtrees/_vcpkg"
buildDir="$baseBuildDir/build"
tarballPath="$downloadsDir/$vcpkgToolReleaseTarball"
srcBaseDir="$baseBuildDir/src"
srcDir="$srcBaseDir/vcpkg-tool-$vcpkgToolReleaseTag"

if [ -e "$tarballPath" ]; then
    vcpkgCheckEqualFileHash "$vcpkgToolUrl" "$tarballPath" "$vcpkgToolReleaseSha"
else
    echo "Downloading vcpkg tool sources"
    vcpkgDownloadFile "$vcpkgToolUrl" "$tarballPath" "$vcpkgToolReleaseSha"
fi

echo "Building vcpkg-tool..."
rm -rf "$baseBuildDir"
mkdir -p "$buildDir"
vcpkgExtractArchive "$tarballPath" "$srcBaseDir"
cmakeConfigOptions="-DCMAKE_BUILD_TYPE=Release -G 'Ninja' -DCMAKE_MAKE_PROGRAM='$ninjaExe'"

if [ "${VCPKG_MAX_CONCURRENCY}" != "" ] ; then
    cmakeConfigOptions=" $cmakeConfigOptions '-DCMAKE_JOB_POOL_COMPILE:STRING=compile' '-DCMAKE_JOB_POOL_LINK:STRING=link' '-DCMAKE_JOB_POOLS:STRING=compile=$VCPKG_MAX_CONCURRENCY;link=$VCPKG_MAX_CONCURRENCY' "
fi

(cd "$buildDir" && CXX="$CXX" eval "$cmakeExe" "$srcDir" $cmakeConfigOptions "-DBUILD_TESTING=$vcpkgBuildTests" "-DVCPKG_DEVELOPMENT_WARNINGS=OFF" "-DVCPKG_ALLOW_APPLE_CLANG=$vcpkgAllowAppleClang") || exit 1
(cd "$buildDir" && "$cmakeExe" --build .) || exit 1

rm -rf "$vcpkgRootDir/vcpkg"
cp "$buildDir/vcpkg" "$vcpkgRootDir/"

if [ "$vcpkgDisableMetrics" = "ON" ]; then
    touch "$vcpkgRootDir/vcpkg.disable-metrics"
elif ! [ -f "$vcpkgRootDir/vcpkg.disable-metrics" ]; then
    # Note that we intentionally leave any existing vcpkg.disable-metrics; once a user has
    # opted out they should stay opted out.
    cat <<EOF
Telemetry
---------
vcpkg collects usage data in order to help us improve your experience.
The data collected by Microsoft is anonymous.
You can opt-out of telemetry by re-running the bootstrap-vcpkg script with -disableMetrics,
passing --disable-metrics to vcpkg on the command line,
or by setting the VCPKG_DISABLE_METRICS environment variable.

Read more about vcpkg telemetry at docs/about/privacy.md
EOF
fi
