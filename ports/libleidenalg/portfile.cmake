vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO theAeon/libleidenalg
    REF "v${VERSION}"
    SHA512 66d7a9e1b039e8fe180b5ca7c7685a661e87abbd317cfacbbd232c80e3c759bb8ababb890161e360d348b47188b07bcc664945b3bea80f0f70216dc5bb8c477e
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
