vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF "${VERSION}"
    SHA512 8b80f0988daea4eb2c827be57de21167f54a9bf3e9704d64d17d12aef064d8ad87d00f95ce4b5add7666452561c5ca42aa45cf677e54068974a4ea813af3b235
    HEAD_REF master
    PATCHES
        disable_tests_enable_static_build.patch
        fix-shared-windows-build.patch
        fix_include_path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME sigc++-3 CONFIG_PATH lib/cmake/sigc++-3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sigc++config.h" "ifdef BUILD_SHARED" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
