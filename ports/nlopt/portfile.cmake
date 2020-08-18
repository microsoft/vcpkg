vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF v2.6.2
    SHA512 61e5c01140a57c0ad2a0acd82ad50dce1b5679dc281e55cbbc332e876b19a689013100617545a42b721d8c487df37d6ccd67859171243433fe29468f259b556b
    HEAD_REF master
    PATCHES
        0001-suppress-MS-compiler-complaint-about-negating-unsign.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNLOPT_FORTRAN=OFF
        -DNLOPT_PYTHON=OFF
        -DNLOPT_OCTAVE=OFF
        -DNLOPT_MATLAB=OFF
        -DNLOPT_GUILE=OFF
        -DNLOPT_SWIG=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nlopt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
