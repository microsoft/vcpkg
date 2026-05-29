vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF "v${VERSION}"
    SHA512 c1e9b8266484085c3775ef77d6b09fd60054ee36bbdc7d56c144bfa0ed2fe66136b3fc423cab26e9a148eccbdc97f1d03ae1d1b158b3a6555f1a703f7824135e
    HEAD_REF master
    PATCHES
        copyright.diff
        no-absolute-paths.diff
        prefer-config.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGDCM_BUILD_DOCBOOK_MANPAGES=OFF
        -DGDCM_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DGDCM_BUILD_TESTING=OFF
        -DGDCM_INSTALL_DATA_DIR=share/${PORT}
        -DGDCM_INSTALL_DOC_DIR=share/${PORT}/doc
        -DGDCM_INSTALL_INCLUDE_DIR=include
        -DGDCM_INSTALL_PACKAGE_DIR=share/${PORT}
        -DGDCM_USE_SYSTEM_EXPAT=ON
        -DGDCM_USE_SYSTEM_OPENJPEG=ON
        -DGDCM_USE_SYSTEM_ZLIB=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Copyright.txt")
