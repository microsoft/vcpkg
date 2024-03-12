vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/CorrelationVector-Cpp
    REF cf38d2b44baaf352509ad9980786bc49554c32e4
    SHA512 f97eaef649ffd010fb79bca0ae6cb7ce6792dcb38f6a5180d04dc6542589d0d727583455bbafb319982cfed1291384180d49c7f32ebe7560b444ec132c76d0c4
    HEAD_REF master
    PATCHES
        "correlation-vector.patch"
)

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME correlation_vector CONFIG_PATH lib/correlation_vector)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Handle usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Remove duplicated include files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove lib dir if empty due to configuration
file(GLOB LIBDIR_FILES "${CURRENT_PACKAGES_DIR}/lib/*")
list(LENGTH LIBDIR_FILES LIBDIR_FILES_LEN)
if(LIBDIR_FILES_LEN EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()
