include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcheck/check
    REF 0.12.0
    SHA512 f7b6452b69f999a90e86a8582d980c0c1b74ba5629ee34455724463ba62bfe3501ad0415aa771170f5c638a7a253f123bf87cbef25aadc6569a7a3a4d10fce90
    HEAD_REF master
    PATCHES
        fix-build-debug-mode.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/check.cmake ${CURRENT_PACKAGES_DIR}/cmake/check-config.cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/check RENAME copyright)

vcpkg_copy_pdbs()
