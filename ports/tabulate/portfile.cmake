# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/tabulate
    REF 24319973289981de2ce6b6afd25f937c9c453abb
    SHA512 d7a3b7c4129a1db2f49a2f7d6e8583bcf8d0cb0a18ae9b5c872c6af6d22ef64266e0bf295af7e91386fecae7c0136ea455e1c0011bb1926912f6c97617c023a3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dtabulate_BUILD_TESTS=OFF
        -DSAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
