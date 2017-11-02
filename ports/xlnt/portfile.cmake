include(vcpkg_common_functions)

set(XLNT_VERSION 1.2.0)
set(XLNT_HASH 359ff1e99531513d7b1228ff07f137531be99d7a95bbc5b399168a6c609f56dba2e030464f8203db92db137ab80dbe10f71de71a62b0bcb96eaafc0f09256339)
set(XLNT_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xlnt-${XLNT_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/tfussell/xlnt/archive/v${XLNT_VERSION}.zip
    FILENAME xlnt-${XLNT_VERSION}.zip
    SHA512 ${XLNT_HASH}
)

vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC OFF)
else()
    set(STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${XLNT_SOURCE_PATH}
    OPTIONS -DTESTS=OFF -DSAMPLES=OFF -DBENCHMARKS=OFF -DSTATIC=${STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(INSTALL ${XLNT_SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/xlnt RENAME copyright)

vcpkg_copy_pdbs()
