vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF 3.0.2
    SHA512 426054403121f84a2ac365f7545b35fb217b41061aebaffce483568d3d374d453ab87987c599a85f1f745e0ec7144a3181ed9b100f354e2823f165ba286b0611
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DINSTALL_PROJECT=ON
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
)

vcpkg_cmake_install()
vcpkg_copy_pdbs(BUILD_PATHS "${CURRENT_PACKAGES_DIR}/bin/*.dll")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/miniz)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
