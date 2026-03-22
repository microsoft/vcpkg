include(CMakePackageConfigHelpers)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linkotec/ffts
    REF "2c8da4877588e288ff4cd550f14bec2dc7bf668c"
    SHA512 66d7b0bb042fb7ca5734c052ca36a6791b4579ca4523c9a6760f08fa112f037b2a8d18f52be12fd63bbd0b2f9fa45a86a1ad58bffd7661afe8bf904549fb0583
    HEAD_REF master
    PATCHES
        exclude-tests.patch
        fix-install.patch
        remove-static-suffix.patch
)

vcpkg_list(SET options)

if (${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    vcpkg_list(APPEND options -DENABLE_SHARED=ON -DENABLE_STATIC=OFF)
else()
    vcpkg_list(APPEND options -DENABLE_SHARED=OFF -DENABLE_STATIC=ON)
endif()

if (${VCPKG_TARGET_IS_WINDOWS} AND ${VCPKG_TARGET_ARCHITECTURE} STREQUAL "x86")
    vcpkg_list(APPEND options -DDISABLE_DYNAMIC_CODE=ON)
else()
    vcpkg_list(APPEND options -DDISABLE_DYNAMIC_CODE=OFF)
endif()

if (${VCPKG_TARGET_IS_ANDROID})
    vcpkg_list(APPEND options -DENABLE_NEON=ON)
else()
    vcpkg_list(APPEND options -DENABLE_NEON=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
    INSTALL_DESTINATION "share/${PORT}"
)
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
