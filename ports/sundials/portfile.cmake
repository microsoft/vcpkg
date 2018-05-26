include(vcpkg_common_functions)

set(ARCHIVE_NAME "sundials-2.7.0")
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/${ARCHIVE_NAME}")

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://computation.llnl.gov/projects/sundials/download/${ARCHIVE_NAME}.tar.gz"
    FILENAME "${ARCHIVE_NAME}.tar.gz"
    SHA512 c86c167538065a4109b36ae7c8f60f3d92184133cfa661b5acfccee052c38f40be865412a1746bb57907b61602c212c0f15e1e30ef29e8a49db6d46a75a28e69
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DEXAMPLES_ENABLE=OFF
)

vcpkg_install_cmake(DISABLE_PARALLEL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB REMOVE_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

file(GLOB DEBUG_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
)

file(GLOB DLLS
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sundials RENAME copyright)

if(REMOVE_DLLS)
    file(REMOVE ${REMOVE_DLLS})
endif()

vcpkg_copy_pdbs()
