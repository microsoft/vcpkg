include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)
set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO opencollab/arpack-ng
    REF ${VERSION}
    SHA512 fbcaa2179dd1aa5a39fc3e7d80f377ec90ddf16ef93184a88e6ecfc464ed97e5659f2cf578294ac3e0b0c0da6408c86acf5bbdce533e1e9d2a3121848340d282
    HEAD_REF master
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ENV{FFLAGS} "$ENV{FFLAGS} -fPIC")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FORTRAN_CMAKE}
        -DMPI=OFF
        -DICB=ON
        -DICBEXMM=OFF
        -DEXAMPLES=OFF
        -DTESTS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME arpackng CONFIG_PATH lib/cmake/arpackng)
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
