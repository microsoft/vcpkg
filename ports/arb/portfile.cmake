include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/arb-2.11.1)
vcpkg_from_github(
    OUT_SOURCE_PATH ${SOURCE_PATH}
    REPO fredrik-johansson/arb
    REF v2.11.1
    SHA512 45d0d7f8cc350
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpfr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mpfr/COPYING ${CURRENT_PACKAGES_DIR}/share/mpfr/copyright)
