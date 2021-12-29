set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(CMAKE_HOST_WIN32 AND VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
    return()
endif()

set(BOOST_VERSION 1.77.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/build
    REF boost-${BOOST_VERSION}
    SHA512 35352daaa31b54ee0bfce764dda0863931ac0e90aa8e3facde26a7ba472ddd2d799fced7cfcca8fc3ffd7a0a7f7e7d095337ba28f200da10e5187b7ef39bb88b
    HEAD_REF master
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-${BOOST_VERSION}/LICENSE_1_0.txt"
    FILENAME "boost_LICENSE_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

vcpkg_download_distfile(BOOSTCPP_ARCHIVE
    URLS "https://raw.githubusercontent.com/boostorg/boost/boost-${BOOST_VERSION}/boostcpp.jam"
    FILENAME "boost-${BOOST_VERSION}-boostcpp.jam"
    SHA512 0daa0dd315f7e426e7b9ada9cc4dad03da2eb257456e551de3fb3b2a8244f0117ed41d9d1ff77b5a3eee7a3c5fb466d345b9bb2af46004fc630209043d4862e3
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
