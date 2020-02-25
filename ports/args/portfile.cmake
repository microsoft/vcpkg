#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF 401663c1d57006566db6d8e5b37a21018fbd0bc3
    SHA512 2e0506f41ee8527e7fb67c0b926ff892fafe79db90920624c84eb603e374eb74c5640e4d0d0d88554db7a57424095b0da96238b4182ac515ae96dc202df95013
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DARGS_BUILD_UNITTESTS=OFF
    -DARGS_BUILD_EXAMPLE=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/LICENSE ${CURRENT_PACKAGES_DIR}/share/args/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()
