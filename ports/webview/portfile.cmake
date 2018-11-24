# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zserge/webview
    REF f390a2df9ec50d1bce389f0656a215a5504dce04
    SHA512 bac2f6071817fb5f9cdcbed3cb25cd6c043a8126b671d2996e48876231f89a4bfefef052f215d445a77c090e744b471e25e6aa6a68f9b7939b8ecdb588e31d1c
    HEAD_REF master
    PATCHES
        fix-msvc.cmake
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/webview RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
