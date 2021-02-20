# Header-only library

vcpkg_fail_port_install(ON_TARGET "UWP" "LINUX" "OSX" "FREEBSD" "ANDROID" "MINGW")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/krabsetw
    REF 74a35d706a25b983ed0f1a830309cf7413f8c2cf
    SHA512 98c830238d8bbe130db64afe8b7f74deb7f311f89b780943d8c9db472a64d6e5f798fa77265995660cea1a5db8fb88984ecc9351c10716b2e3a25b5d0665482d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/krabs/krabs/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/krabs)
file(INSTALL ${SOURCE_PATH}/krabs/krabs.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
