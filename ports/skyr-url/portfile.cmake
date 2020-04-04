vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.5.1
        SHA512 0259b6eed43e480779d35990bdebd32bdbd3c30a548fba46a6b03afd742c3fd862d2a2cba6f49a6baf669763e7701c12b457530e424f2b7175533911e911ae3b
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/skyr-url RENAME copyright)
