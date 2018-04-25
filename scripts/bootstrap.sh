#!/bin/sh

# The current system name
UNAME="$(uname)"

# Find vcpkg-root
vcpkgRootDir=$(X= cd -- "$(dirname -- "$0")" && pwd -P)
while [ "$vcpkgRootDir" != "/" ] && ! [ -e "$vcpkgRootDir/.vcpkg-root" ]; do
    vcpkgRootDir="$(dirname "$vcpkgRootDir")"
done

downloadsDir="$vcpkgRootDir/downloads"

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
        echo "sudo apt-get install curl unzip tar"
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

    # shasum returns [hash filename], so get the first word
    actualHash="${actualHash%% *}"

    if ! [ "$expectedHash" = "$actualHash" ]; then
        echo ""
        echo "File does not have expected hash:"
        echo "              url: [ $url ]"
        echo "        File path: [ $downloadPath ]"
        echo "    Expected hash: [ $sha512 ]"
        echo "      Actual hash: [ $actualHash ]"
        exit
    fi
}

vcpkgDownloadFile()
{
    url=$1; downloadPath=$2 sha512=$3
    vcpkgCheckRepoTool "curl"
    rm -rf "$downloadPath.part"
    curl -L $url --create-dirs --output "$downloadPath.part" || exit 1

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

# err outputs a message to stderr, then quits with error code 1
err()
{
    echo "$*" >/dev/stderr
    exit 1
}

# mustToolVersion must output the version number for the given tool name on
# stdout, or exit with an error message and error code 0.
# Takes the tool name as an argument
mustToolVersion()
{
    tool="$1"
    if [ "$tool" = "" ]; then
        err "No tool name provided"
    fi

    if [ "$UNAME" = "Linux" ]; then
        os="linux"
    elif [ "$UNAME" = "Darwin" ]; then
        os="osx"
    else
        err "Unknown uname: $UNAME"
    fi

    xmlFileAsString=`cat $vcpkgRootDir/scripts/vcpkgTools.xml`
    toolRegexStart="<tool name=\"$tool\" os=\"$os\">"
    toolData="$(extractStringBetweenDelimiters "$xmlFileAsString" "$toolRegexStart" "</tool>")"
    if [ "$toolData" = "" ]; then
        err "Unknown tool: $tool"
    fi

    echo -n "$(extractStringBetweenDelimiters "$toolData" "<version>" "</version>")"
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
    else
        echo "Unknown uname: $UNAME"
        return 1
    fi

    xmlFileAsString=`cat "$vcpkgRootDir/scripts/vcpkgTools.xml"`
    toolRegexStart="<tool name=\"$tool\" os=\"$os\">"
    toolData="$(extractStringBetweenDelimiters "$xmlFileAsString" "$toolRegexStart" "</tool>")"
    if [ "$toolData" = "" ]; then
        echo "Unknown tool: $tool"
        return 1
    fi

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
        echo "Downloading $tool $version..."
        vcpkgDownloadFile $url "$downloadPath" $sha512
        echo "Downloading $tool $version... done."
    else
        vcpkgCheckEqualFileHash $url "$downloadPath" $sha512
    fi

    if [ $isArchive = true ]; then
        echo "Extracting $tool $version..."
        vcpkgExtractArchive "$downloadPath" "$toolPath"
        echo "Extracting $tool $version... done."
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
    __output=$1

    if [ "x$CXX" = "x" ]; then
        CXX=g++
        if which g++-8 >/dev/null 2>&1; then
            CXX=g++-8
        elif which g++-7 >/dev/null 2>&1; then
            CXX=g++-7
        elif which g++-6 >/dev/null 2>&1; then
            CXX=g++-6
        fi
    fi

    gccversion="$("$CXX" -v 2>&1)"
    gccversion="$(extractStringBetweenDelimiters "$gccversion" "gcc version " ".")"
    if [ "$gccversion" -lt "6" ]; then
        echo "CXX ($CXX) is too old; please install a newer compiler such as g++-7."
        echo "sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y"
        echo "sudo apt-get update -y"
        echo "sudo apt-get install g++-7 -y"
        return 1
    fi

    eval $__output="'$CXX'"
}

selectCMake()
{
    cmakeVersion="$(mustToolVersion cmake)"
    cmakeSysVersion="$(cmake --version 2>/dev/null | head -1 | cut -d' ' -f3)"
    highestVersion=$(echo "$cmakeVersion/$cmakeSysVersion" | tr / '\n' | sort -Vr | head -1)
    if [ "$cmakeSysVersion" = "$highestVersion" ]; then
        # Using the system version of cmake, since it's newer
        cmakeExe="$(which cmake)"
        return
    fi
    # The wanted version of CMake is newer than the system version of cmake,
    # or cmake is missing.
    fetchTool "cmake" "$UNAME" cmakeExe || return 1
}

selectNinja()
{
    ninjaVersion="$(mustToolVersion ninja)"
    ninjaSysVersion="$(ninja --version 2>/dev/null)"
    highestVersion=$(echo "$ninjaVersion/$ninjaSysVersion" | tr / '\n' | sort -Vr | head -1)
    if [ "$ninjaSysVersion" = "$highestVersion" ]; then
        # Using the system version of Ninja, since it's newer
        ninjaExe="$(which ninja)"
        return
    fi
    # The wanted version of Ninja is newer than the system version of ninja,
    # or ninja is missing.
    fetchTool "ninja" "$UNAME" ninjaExe || return 1
}

# Preparation
selectCMake || exit 1
selectNinja || exit 1
selectCXX CXX || exit 1

# Do the build
buildDir="$vcpkgRootDir/toolsrc/build.rel"
rm -rf "$buildDir"
mkdir -p "$buildDir"

(cd "$buildDir" && CXX=$CXX "$cmakeExe" .. -DCMAKE_BUILD_TYPE=Release -G "Ninja" "-DCMAKE_MAKE_PROGRAM=$ninjaExe")
(cd "$buildDir" && "$cmakeExe" --build .)

rm -rf "$vcpkgRootDir/vcpkg"
cp "$buildDir/vcpkg" "$vcpkgRootDir/"
