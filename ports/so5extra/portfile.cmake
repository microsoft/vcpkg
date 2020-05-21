vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/so5extra
    REF 5bf200f495fd7774bd1e42ee563db8c69ad6fc75 # v.1.4.0
    SHA512 3d91505d2a58a6fd0fd8fc9296996cfe26dece40f9f7b8364d9d65d2046d290b98f0c6e5e48371e5fc729b17a35e55c7571f78dca45bb697c422c133aa24ff1e
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

