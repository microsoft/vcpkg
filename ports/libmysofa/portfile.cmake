vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoene/libmysofa
    REF "v${VERSION}"
    SHA512 58bd056678503491292a8a9b6b3f43451995a2c0a16735e4ae474d2d3e49bd7b3d6ef3dbfd0ce78e30d9f70887dd9cac60a8fae05ece0c167414f8ac4d3d5514
    HEAD_REF main
    PATCHES
      use-vcpkg-zlib.patch
)

# default.sofa is a symlink to MIT_KEMAR_normal_pinna.sofa, 
# which can cause problems e.g. on Windows file systems.
if(EXISTS "${SOURCE_PATH}/share/default.sofa")
    file(REMOVE "${SOURCE_PATH}/share/default.sofa")
endif()
file(COPY_FILE "${SOURCE_PATH}/share/MIT_KEMAR_normal_pinna.sofa" "${SOURCE_PATH}/share/default.sofa")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mysofa CONFIG_PATH lib/cmake/mysofa)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
