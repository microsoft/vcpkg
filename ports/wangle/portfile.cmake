vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF 4bf3896ad5e938a01ba20efaf1ea59317d846fb2 # v2020.10.19.00
    SHA512 1c21199225ebfe9a95391c2bb607412ebadc7aac326373e30dc9d49223a2437b382b4c3160fb2147a505bc2182f03f651c95f7c67f916e336ac81af76884f5fa
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
