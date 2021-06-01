vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF v2021.05.31.00
    SHA512 b99138dd4ad8a2e2de48ec2840ce0cb1e43d08a356d6bf66f7f0d300d45a7e325799c538d7c9de2215c9ef96cdb5c84b2aa267282c251c8b8b00a50a703bab72
    HEAD_REF master
    PATCHES
        fix-config-cmake.patch
        fix_dependency.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/wangle"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/wangle)

file(READ ${CURRENT_PACKAGES_DIR}/share/wangle/wangle-targets.cmake _contents)
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/wangle/wangle-targets.cmake "${_contents}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/include/wangle/util/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/ssl/test/certs
    ${CURRENT_PACKAGES_DIR}/include/wangle/service/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/deprecated/rx/test
)

file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
