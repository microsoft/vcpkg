vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.7.4-1
        SHA512 a6e69b1c2922763f72e03011b72ade962e346d160f5691480e7b1c679d8a47dec5711a696c7a937200d178f42a5d2bf3138965b66ced76d47aea636b93a8d286
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
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
