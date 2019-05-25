include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF b8fd56c61ed1ec6cd288ff4a0105a49e853e3e08
    SHA512 755982b512f669383a8319e9080b51f2fbb82756472af7fbf0555385f1b15d111e7223ecc1b70c2eade8c1ec1c7c0ccc478f9976ad45e04385bbb59039e66a4c
    HEAD_REF master
    PATCHES
        build.patch
        fix-config-cmake.patch
)
# message(FATAL_ERROR "patch")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/wangle"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/wangle")

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

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wangle RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/wangle)
