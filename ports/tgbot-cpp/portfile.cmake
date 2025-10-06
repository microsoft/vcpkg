vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO reo7sp/tgbot-cpp
    REF "v${VERSION}"
    SHA512 34eac9aac2cbf6025bde24c1a2bdb79b143a18b8fffd81e51340ee3cbb61338b1747e3d54c2d8b0f99e381231756bf11daa4b6ba4da1fd0a1ef40969dee7c647
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DBUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TgBot")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
