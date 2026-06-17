vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF "v${VERSION}"
    SHA512 527c5ac581e67d07815ed97fd3ac8d2280230a1a9b4f2b8995cebcf2008049270f5a6225081b7738b1e0a6d870b2a352b48f2e0d3dc50b528249146772e516ef
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
