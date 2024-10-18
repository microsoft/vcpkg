vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF "v${VERSION}"
    SHA512 2fe28444cee171a536d63f26c1ad7308a03b946e79dc8b7d648b5c7e6f4a8f52c0c32ec9cf463d95b876db31becc81541638b97fc7f15b79ae04de5988d6941e
    HEAD_REF master
    PATCHES
        copyright.diff
        include-no-namespace.diff
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
