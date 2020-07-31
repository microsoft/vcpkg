vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.12.0
        SHA512 b17b3bf6bb00ba5008b0da23f6a1977cdd154026c7887a59c6cf81351378c0803249ce0a3c53812456633c2971205a5514940a282a0fbaf8f91ce808fba7c753
        HEAD_REF main
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
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
