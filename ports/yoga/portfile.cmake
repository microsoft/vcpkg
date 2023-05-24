vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/yoga
    REF 220d2582c94517b59d1c36f1c2faf5e3f88306f1
    SHA512 fbb3d2bb4e48f571f25aab140fbda89472f0800128487141f4cb5b53e121017b06535e7bfd3a0f9f1ba726845e0b90da26da1b428a1d4b7c23d751635d4115cf
    HEAD_REF master
    PATCHES
        disable_tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
