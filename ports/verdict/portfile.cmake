vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  sandialabs/verdict
    REF 6ea66d8e3c115049eea71ae372988deba6ab1b0b
    SHA512 a47de77f1b23f3fedfaa3c618955ec7e3da44959b116708237af770e32bd43b356063e0e800e7e8a011a0f43e1058b68b11675978034a616d2e03d1c83db9356
    HEAD_REF master
    PATCHES fix_osx.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERDICT_ENABLE_TESTING=OFF
        -DCMAKE_CXX_STANDARD=14
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/verdict" PACKAGE_NAME verdict)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

