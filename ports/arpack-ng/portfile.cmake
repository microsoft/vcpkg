include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "opencollab/arpack-ng"
    REF "6be238e7039c98723edf523455a627b39788acba"
    SHA512 4680373ebccfbba082eae8130020822095b0839553ae2541a4ac4aa679091dc255ce5140b9807e2d50cf4ceb6d90e0bf4547448931e1a564e3d8c67523c13002
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
