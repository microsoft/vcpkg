include(vcpkg_common_functions)

set(XLNT_REV 9dccde4bff34cfbafbdc3811fdd05326ac6bd0aa)
set(XLNT_HASH 85bb651e42e33a829672ee76d14504fcbab683bb6b468d728837f1163b5ca1395c9aa80b3bed91a243e065599cdbf23cad769375f77792f71c173b02061771af)
set(XLNT_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xlnt-${XLNT_REV})

vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/tfussell/xlnt/archive/${XLNT_REV}.zip
    FILENAME xlnt-${XLNT_REV}.zip
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
