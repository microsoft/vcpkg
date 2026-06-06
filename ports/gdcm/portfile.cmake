vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF "v${VERSION}"
    SHA512 3d9eebd7788a71d8a329b33d18b329c2f4a17f4d5c5866639854c33f567b8316bd6b23a926164368b71b8203d906381cf9942c599724e042ad41308e2efc2cb9
    HEAD_REF master
    PATCHES
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
