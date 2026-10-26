vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier-orm
    REF dc4dcbea52256ed07a485a6a1c7d0f44c57a4405
    SHA512 e18fd14b683af4b33f8c7d9a3d459436d51efd56f467f66113759289f7491c3dca4ece6cd490fe7ea06893db5a0124b9710dc208b7faec2f56cae9e69838c44e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier-orm"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME brazier-orm CONFIG_PATH share/brazier-orm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")