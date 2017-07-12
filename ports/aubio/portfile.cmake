include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aubio-3c230fae309e9ea3298783368dd71bae6172359a)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aubio/aubio/archive/3c230fae309e9ea3298783368dd71bae6172359a.zip"
    FILENAME "aubio-0.4.6-3c230f.zip"
    SHA512 081fe59612f0b1860f465208739b1377869c64b91cecf4a6f6fbdea19204b801c650ff956b34be5988ef1905f3546d3c55846037487e0b34b014f1adbb68629c
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_RELEASE
    -DTOOLS_INSTALLDIR=tools/aubio
    -DBUILD_TOOLS=ON
  OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=1
    -DBUILD_TOOLS=OFF
)
vcpkg_install_cmake()

# Handle copyright and credentials
file(COPY
    ${SOURCE_PATH}/COPYING
    ${SOURCE_PATH}/AUTHORS
    ${SOURCE_PATH}/ChangeLog
    ${SOURCE_PATH}/README.md
  DESTINATION
    ${CURRENT_PACKAGES_DIR}/share/aubio)

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/aubio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/aubio/COPYING ${CURRENT_PACKAGES_DIR}/share/aubio/copyright)
