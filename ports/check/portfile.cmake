vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcheck/check
    REF d86594e5b29d50ddbd6276ab2d2cf5c278f7656c # 0.14.0
    SHA512 db9c27fdce5c238b6327dd43dec3aa0321e2a1af49d17218db8a7fb96e8f07750cbc51cf8a07504700d878d97334c1703b165a17da1c070d43aa2c15a67e977d
    HEAD_REF master
    PATCHES fix-lib-path.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/check)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)