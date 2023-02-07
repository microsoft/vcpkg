vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mozilla/cubeb
    REF dc511c6b3597b6384d28949285b9289e009830ea
    SHA512 a4ccd3f0a156db4e2e75a8d231e95a08d555390571551cb3e92c71cdee46dc74dc66b5272fda4b5f1f083b92672b360152cefd38be242f238fe802acc1ea17e9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_SANITIZERS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cubeb)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
