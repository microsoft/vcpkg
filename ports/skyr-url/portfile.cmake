vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.4.3
        SHA512 b76157d91d4fb0d53ef03dbaa18e898a77c75afaa5bf1aea1aae71ef2506ba3d11ee1df9f2ca5420e79b4a572841e2e4cfac4f3a7fb7ecc36ab086ce5a027380
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
