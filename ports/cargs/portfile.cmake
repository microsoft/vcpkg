vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO likle/cargs
    REF v1.0.2
    SHA512 fdd1bb7c93c741a46c6ef056cc8ce1ff66172059639b463fca9bce6294bb4c3873312d94b28c7a1ee9a3a05cb2df0c30366ee4428554b274d722c55fd88be2b6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cargs)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
