vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Naios/function2
    REF d2acdb6c3c7612a6133cd03464ef941161258f4e
    SHA512 298f39db3c4e7a599e41fef71d1f953f3c5e20bc9f4af378c67bd47c10b126efd7be80be4ad919370a1151c8c5bc111ccd9054757a1aaf1ccf3f87ca958a7e3a
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE ${CURRENT_PACKAGES_DIR}/Readme.md)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Put the installed licence file where vcpkg expects it
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()
