vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO census-instrumentation/opencensus-cpp
    REF 2b0725c2d0f809351300c634c54e70e0a8c3f4ed #v0.4.0
    SHA512 16f3975ed0580aec83e0dd98f15a04d614cf45bfa7e07b0b94e881afc12e8e4bac3c0efde1f8e7da9f5dc66365415ae1e3ab10dfcbd9e078879246db6e81cd56 
    HEAD_REF master
    PATCHES fix-install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTING
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
