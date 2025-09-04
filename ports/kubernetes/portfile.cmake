vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF "v${VERSION}"
    SHA512 4cee597f81a0181ba9a3dee9c7f01b7e55cba939fc3367d1d314aeb6a39044701886fe4b7f8eb72e890aafed653afa0f2f36cbd3aaa91ee85cf581f1b1eaec85
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
        002-disable-werror.patch
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
