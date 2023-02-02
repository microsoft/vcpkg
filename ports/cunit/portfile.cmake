set(VERSION 2.1)
set(RELEASE 3)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cunit/CUnit
    REF "${VERSION}-${RELEASE}"
    FILENAME "CUnit-${VERSION}-${RELEASE}.tar.bz2"
    SHA512 547b417109332446dfab8fda17bf4ccd2da841dc93f824dc90a20635bcf1fb80fb2176500d8a0906940f3f3d3e2f77b2d70a71090c9ab84ad9af43f3582bc487
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    "-DVERSION=${VERSION}"
    "-DRELEASE=${RELEASE}"
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-cunit)
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
