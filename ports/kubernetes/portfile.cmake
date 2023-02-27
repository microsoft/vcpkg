vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF "v${VERSION}"
    SHA512  9a485b8788da2b69695c7c312209602ed4777c29e2fe9bdd6b0c5f62169cb152373ec95fae60553ea70810c852cb41467524ad9b91c5e11fe02efe2678b79250
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
