vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.4.5
        SHA512 39501217e331a904daf928a5874f81808a9665a9e8debe39c15a3fb7607ab293a5a1b335062cc7ac8f4fe239d4233a2c5ed0e9b45dbec7edcc267eb3d25509d3
        HEAD_REF master
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DSkyr_BUILD_TESTS=OFF
            -DSkyr_BUILD_DOCS=OFF
            -DSkyr_BUILD_EXAMPLES=OFF
            -DSkyr_WARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/skyr-url RENAME copyright)
