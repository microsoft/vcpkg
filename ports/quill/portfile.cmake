vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 9cf2e89eb4ccda23ec2965b3b51390e06bef04dec269ce45e45d67fa964a571b19f22c6f4a3003d19ca8029c57b58047261ab860b4b8ef873345e99f2b6321b9
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
