vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChristianPanov/lwlog
    REF "v${VERSION}"
    SHA512 882bedcbab5c68c9c10874aa0531e6c25416e7b0922eeec2ba7081a9a6e19bd35b4d2b64b7d2a7b3baae5a650f428f2cd21a7e796ff5caa91fe94518ea50f76f
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME lwlog_lib CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
