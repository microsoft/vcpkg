vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO accellera-official/systemc
    REF "${VERSION}"
    SHA512 a37fb401c23939c5fd79664d624b2af4f7e99f0aad386b0e0cb4476086225df637763ca66fa6e65d5f6bb2e80349508d03e8f834c6bcc636a022ea64fc78e274
    HEAD_REF main
    PATCHES
        install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DDISABLE_COPYRIGHT_MESSAGE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SystemCLanguage PACKAGE_NAME systemclanguage)
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/SystemCTLM PACKAGE_NAME systemctlm)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/sysc/packages/boost"
    "${CURRENT_PACKAGES_DIR}/include/sysc/packages/qt/time"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE")
