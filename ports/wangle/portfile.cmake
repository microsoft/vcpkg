vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF "v${VERSION}"
    SHA512 d3aa8dc6ef184356f520341b858d9064f18a413cccec52d541cb4fc7895f700c1cbbf00ede7ee8ac52d6cc7c0779e68c6078a475ace25f24854c706bbe462798
    HEAD_REF main
    PATCHES
        fix-config-cmake.patch
        fix_dependency.patch
)

file(REMOVE
  "${SOURCE_PATH}/wangle/cmake/FindDoubleConversion.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGflags.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGlog.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGMock.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindLibEvent.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindSodium.cmake"
  "${SOURCE_PATH}/build/fbcode_builder/CMake/FindZstd.cmake"
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/wangle"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wangle)

file(READ "${CURRENT_PACKAGES_DIR}/share/wangle/wangle-targets.cmake" _contents)
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/wangle/wangle-targets.cmake" "${_contents}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/wangle/util/test"
    "${CURRENT_PACKAGES_DIR}/include/wangle/ssl/test/certs"
    "${CURRENT_PACKAGES_DIR}/include/wangle/service/test"
    "${CURRENT_PACKAGES_DIR}/include/wangle/deprecated/rx/test"
)

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
