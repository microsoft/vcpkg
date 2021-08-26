vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kiconthemes
    REF v5.84.0
    SHA512 ca5645d6e4fde4f60c6f16c911539f4056060cc22afae275459632bc7069352b068b1727eb75b898d319e6eef3df9ddc35d8e22d4c1d05a657b112378e56731e
    HEAD_REF master
    PATCHES
        39.patch
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5IconThemes)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kiconfinder5
    AUTO_CLEAN
)

if(VCPKG_TARGET_IS_OSX)
    vcpkg_copy_tools(
        TOOL_NAMES ksvg2icns
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")