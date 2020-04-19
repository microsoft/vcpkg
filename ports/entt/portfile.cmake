vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KomodoPlatform/entt
    REF v3.3.0
    SHA512 98ce01a3a7b1d1fe4f9b3f2db6505944b811c63e968dded9c31c8ba18f00dbae701ccc387e38a4f65ee6d4e581a3686009adbd2286b6014a017a93fa43803cdf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/entt)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/entt RENAME copyright)
