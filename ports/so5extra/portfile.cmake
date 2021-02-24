vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF e03e025b08921c76a650656019a04cf7500620be # v.1.4.1
    SHA512 0ee7b98d713cf5c8789f3275f96e7e92b33cb8d3c44fd98752c11cab07914cb3b104ccaf346e714afd43e115ef854dccb4d04ea37d9063b20947aa0d514dac52
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev/so_5_extra
    PREFER_NINJA
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/so5extra)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)

