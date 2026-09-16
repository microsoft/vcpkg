#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/cc.ublox.generated
    REF v${VERSION}
    SHA512 3e923b9a9e27db6ed80687a0b1c07bf371f5612f8142cfe3efbd69d69a6523017972dbd9071981a936ca2fad7f1a9ac66f6a08de9f0be60900e7f38d0816008d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPT_REQUIRE_COMMS_LIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cc_ublox CONFIG_PATH lib/cc_ublox/cmake)
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/cc_ublox/cc_ubloxConfig.cmake"
    "# Compute the installation prefix relative to this file."
    "include(CMakeFindDependencyMacro)\nfind_dependency(LibComms CONFIG)\n\n# Compute the installation prefix relative to this file."
)
# currently this is only a header only library. after moving lib/ublox to share this lib path will be empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
