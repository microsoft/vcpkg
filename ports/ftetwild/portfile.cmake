vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "SpiriMirror/fTetwild"
    REF "${VERSION}"
    SHA512 d69f2a073ca3e79ad93a9d9739027033c62139f20e030801d73c69913c9a961b0f1be2ba184249ab86c8e283a25e9462d28d60cbe48ea622fc0523aa84cc9496
    HEAD_REF mini20
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MPL2")