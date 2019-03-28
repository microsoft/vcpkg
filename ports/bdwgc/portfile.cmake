include(vcpkg_common_functions)
set(BDWGC_VERSION 8.0.4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gc-${BDWGC_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ivmai/bdwgc/releases/download/v${BDWGC_VERSION}/gc-${BDWGC_VERSION}.tar.gz"
    FILENAME "gc-${BDWGC_VERSION}.tar.gz"
    SHA512 57ccca15c6e50048d306a30de06c1a844f36103a84c2d1c17cbccbbc0001e17915488baec79737449982da99ce5d14ce527176afae9ae153cbbb5a19d986366e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()

# install files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# LIB
if (VCPKG_CRT_LINKAGE STREQUAL static)
    set(LIBNAME "gcmt-lib.lib")
else()
    set(LIBNAME "gcmt-dll.lib")
endif()

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${LIBNAME}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib RENAME gc.lib)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/gcmt-dll.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/bin RENAME gc.dll)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${LIBNAME}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME gc.lib)
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gcmt-dll.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin RENAME gc.dll)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.QUICK DESTINATION ${CURRENT_PACKAGES_DIR}/share/bdwgc RENAME copyright)
