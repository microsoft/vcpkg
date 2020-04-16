vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.7.0
        SHA512 ea1f4cd0d42ef024f68a5b8f97da8a862b091c15162af71748a44175d5795492e0a358995ae04bfa8e75f5d92a65e9f9063b25b85cebd47f191f6352a559416f
        HEAD_REF master
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -Dskyr_BUILD_TESTS=OFF
            -Dskyr_BUILD_DOCS=OFF
            -Dskyr_BUILD_EXAMPLES=OFF
            -Dskyr_WARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/skyr-url RENAME copyright)
