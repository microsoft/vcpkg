include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/2018-03-28/OGDF-snapshot)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.ogdf.net/lib/exe/fetch.php/tech%3aogdf-snapshot-2018-03-28.zip"
    FILENAME "ogdf-2018-03-28.zip"
    SHA512 a6ddb33bc51dca4d59fcac65ff66459043b11ce5303e9d40e4fc1756adf84a0af7d0ac7debab670111e7a145dcdd9373c0e350d5b7e831b169811f246b6e19b6
)
vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src/2018-03-28)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOIN_INSTALL_LIBRARY_DIR:STRING=lib
        -DCOIN_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
        -DOGDF_INSTALL_LIBRARY_DIR:STRING=lib
        -DOGDF_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OGDF)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ogdf RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/minisat/doc ${CURRENT_PACKAGES_DIR}/include/ogdf/lib/minisat/doc)
