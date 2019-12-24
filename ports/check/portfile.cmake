vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcheck/check
    REF 0.13.0
    SHA512 7943021c5bc3b5ca7bc552f6fe1287e384724d69e5bb128d58256692e810b194e506fc1b65ea4fed27d065e2176e7371483e918beb48125abfe3b6f1ca68eb8f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/check)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/check RENAME copyright)

vcpkg_copy_pdbs()