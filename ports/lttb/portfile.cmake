vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO parkertomatoes/lttb-cpp
    REF "${VERSION}"
    SHA512 af958e704ee1559d3a3913dde2a483b321d61d25b47a57b481463bc87544841a5af22524715e2c3479e35d6d202a96fcb670686aea846d216a0af7e4cd91fe15
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH share/lttb/cmake
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
