vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF v2.2.0
    SHA512 b7f00b1575b83ffad66e6fa555b2e420f1178ddf5b9aed64ae2c3af583e3d6c7292f0280e97cb91d4048cd0d0464ea89805f38444b86b7724abe03503682ac7f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
