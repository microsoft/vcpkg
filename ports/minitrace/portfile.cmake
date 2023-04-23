vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hrydgard/minitrace
    REF 6eda75d7e77d37d1674cdd837f74859586772719
    SHA512 6061a63b3aa39ae8b884d84b599d9cf8e0bc70b5c62eb1214edb6399178fc48605b64097a67d928730136fedb6a08670785e23d77e035a5e420036016cbc1fe8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/minitrace" RENAME copyright)
