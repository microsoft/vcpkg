include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(FATAL_ERROR "This library doesn't support x86 arch. Please use x64 instead. If it is critical, create an issue at the repo: github.com/luncliff/coroutine")
endif()

# changed to 1.4.2
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF 74467cb470a6bf8b9559a56ebdcb68ff915d871e
    SHA512 5d61a23c5fe33c544943659dedecff487bb20f288f9c99f137f37bb777317672f299599b740e53cae42c355595fdfdffe183ade39e828b1f3b4aa821a47cb50e
    HEAD_REF        master
)

# package: 'ms-gsl'
set(GSL_INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include
    CACHE PATH "path to include C++ core guideline support library" FORCE)
message(STATUS "Using ms-gsl at ${GSL_INCLUDE_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_INCLUDE_DIR=${GSL_INCLUDE_DIR}
        -DTEST_DISABLED=True
)

vcpkg_install_cmake()

file(
    INSTALL     ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/coroutine
    RENAME      copyright
)

# removed duplicates in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
