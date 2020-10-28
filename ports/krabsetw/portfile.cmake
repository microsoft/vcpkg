# Header-only library

vcpkg_fail_port_install(ON_TARGET "UWP" "LINUX" "OSX" "FREEBSD" "ANDROID" "MINGW")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/krabsetw
    REF 66294b50b75a38545eb93175baa84300a0190b59
    SHA512 74ad4eda261a576a659824e7d0bcbc653a36da8d0128fa6ef46472201eb9200f867414a6be7b8d5f967419fcd82dfc4b3458697256eec51cbd82cd60801f4a38
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/krabs/krabs/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/krabs)
file(INSTALL ${SOURCE_PATH}/krabs/krabs.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
