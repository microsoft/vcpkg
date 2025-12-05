vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dudenzz/moda
    REF "${VERSION}"
    SHA512 87d457d739b1a92ceb513465b18a8a05d246c2e2845555fc9ee659e953721957a865e2dbf03105f3a2c9386ebb415c1a7a1d8d510db90f7e7a8e08b049589e15 #
    HEAD_REF cmake-sample-lib
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()


vcpkg_cmake_config_fixup(PACKAGE_NAME "moda" CONFIG_PATH lib/${PACKAGE_NAME})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

