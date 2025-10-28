vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF "v${VERSION}"
    SHA512 0cddc98f6c3d9e2c550e79611a4a0b97bcf406ea18d3fc068fd95f8d1ef81d9faaaa3277f482fa6265e6571414e22ee8a41ad847839578b43b717096a36a5e1f
    HEAD_REF master
)

if(VCPKG_TARGET_IS_ANDROID)
    set(ADDITIONAL_OPTIONS -DQUILL_NO_THREAD_NAME_SUPPORT=ON)
endif()

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS ${ADDITIONAL_OPTIONS})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/quill)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
