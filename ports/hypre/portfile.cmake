include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hypre-2.11.1/src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods/download/hypre-2.11.1.tar.gz"
    FILENAME "hypre-2.11.1.tar.gz"
    SHA512 4266c1b5225bcc97781246475100382f4929d7c918c854570a36b90602e8f111a4893cd1c93b95c68305c851898b970dd92ac173efe9211be5bb914d3c3c5d83
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-root-cmakelists.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-macro-to-template.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-blas-vs14-math.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-lapack-vs14-math.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-export-global-data-symbols.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(OPTIONS -DHYPRE_SHARED=ON)
else()
  set(OPTIONS -DHYPRE_SHARED=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
    OPTIONS_RELEASE
        -DHYPRE_BUILD_TYPE=Release
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
    OPTIONS_DEBUG
        -DHYPRE_BUILD_TYPE=Debug
        -DHYPRE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/../COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/hypre/copyright)
