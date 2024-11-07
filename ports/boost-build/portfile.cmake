set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(CMAKE_HOST_WIN32 AND VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
    return()
endif()

set(BOOST_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/build
    REF boost-${VERSION}
    SHA512 0214861d3c93f64fd3d211631304a42783eb019df946a4b6ed216163aa9d22b609056c6d1e8dcd62f5f00e9963aa56e84818f01d94465debfc615999baad6bab
    HEAD_REF master
    PATCHES
        0002-fix-get-version.patch
        0003-fix-emscripten.patch
        0004-workaround-MSVC-codegen-bug-in-17.5-on-ARM64.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-${BOOST_VERSION}/LICENSE_1_0.txt"
    FILENAME "boost_LICENSE_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

vcpkg_download_distfile(BOOSTCPP_ARCHIVE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-${BOOST_VERSION}/boostcpp.jam"
    FILENAME "boost-${BOOST_VERSION}-boostcpp.jam"
    SHA512 8bbd436749a1079ad2fb77cdf65b893f35260a9bdd52b360180780e83ff0f90595693f27641745d6db3a7dbc0e3ba5947e23790e99a8aeb94bfc5fb910d16df6
)

# https://github.com/boostorg/boost/pull/206
# do not add version suffix for android
file(READ "${BOOSTCPP_ARCHIVE}" _contents)
string(REPLACE "aix &&" "aix android &&" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/boostcpp.jam" "${_contents}")

file(INSTALL ${ARCHIVE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-build RENAME copyright)

# This fixes the lib path to use desktop libs instead of uwp -- TODO: improve this with better "host" compilation
string(REPLACE "\\store\\;" "\\;" LIB "$ENV{LIB}")
set(ENV{LIB} "${LIB}")

file(COPY
    ${SOURCE_PATH}/
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/boost-build
)

file(READ "${CURRENT_PACKAGES_DIR}/tools/boost-build/src/tools/msvc.jam" _contents)
string(REPLACE " /ZW /EHsc " "" _contents "${_contents}")
string(REPLACE "-nologo" "" _contents "${_contents}")
string(REPLACE "/nologo" "" _contents "${_contents}")
string(REPLACE "/Zm800" "" _contents "${_contents}")
string(REPLACE "<define>_WIN32_WINNT=0x0602" "" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/tools/boost-build/src/tools/msvc.jam" "${_contents}")

message(STATUS "Bootstrapping...")
if(CMAKE_HOST_WIN32)
    if(VCPKG_TARGET_IS_MINGW)
        set(TOOLSET mingw)
    else()
        set(TOOLSET msvc)
    endif()
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/tools/boost-build/bootstrap.bat" ${TOOLSET}
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/boost-build
        LOGNAME bootstrap-${TARGET_TRIPLET}
    )
else()
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/tools/boost-build/bootstrap.sh"
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/boost-build
        LOGNAME bootstrap-${TARGET_TRIPLET}
    )
endif()
