include(vcpkg_common_functions)

set(XLNT_VERSION 1.1.0)
set(XLNT_HASH f0c59a2b241c6b219fbd8bb39705847e2b31332e413bc4aff7e0a8d4d4b9ef6750c03ecc49a196f647fdf60c3bec9f06c800bdb53b56648d2ba9fab359623f95)
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
file(INSTALL ${XLNT_SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/xlnt RENAME copyright)

vcpkg_copy_pdbs()
