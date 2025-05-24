vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 9371a9530e801d28c25bbc202a2c85404e08d6285c77291aeadc67c733de0535067496ed75916a668cb110ed3d6485eee0eb277e1748b5383157c4795b6a9219
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
