vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.4.4
        SHA512 d7ef1156a92b76ae0708dd6cd500f719aa2355b69077ce8e0c9ab3f35f3673857f11128d7050df749850517a4069bf486f1359ad8fbd3c8aad2ce7a450a36668
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
