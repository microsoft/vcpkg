vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF v8.2.2
    SHA512 da6a2de30f096610ea1c0de1ff7a3ab434debaa39199bc1426daff620901fc76e5747e43171d742b17f4afa3c77ef447cba4fda69d76a711e108f3f03af917ca
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_cplusplus=ON
        -Denable_docs=OFF
        -DCFLAGS_EXTRA=-I${CURRENT_INSTALLED_DIR}/include # for libatomic_ops
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bdwgc)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/README.QUICK" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
