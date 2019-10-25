vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO census-instrumentation/opencensus-cpp
    REF 2b0725c2d0f809351300c634c54e70e0a8c3f4ed #v0.4.0
    SHA512 7533a4b0578c8757a4cdece24d09d3ed081d3585fc97342970c63f919aa235d99a0b9d5d8591ec07f9d19d9356b2cdad96e885eb8205c25e82ab476329d4e355 
    HEAD_REF master 
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
