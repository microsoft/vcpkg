vcpkg_buildpath_length_warning(37)

set(OMPL_VERSION 1.4.2)
set(OMPL_DISTNAME "ompl")
set(OMPL_CHECKSUM "1dc477ee471c0570fd94838b072105960e09186f29634e2f61d885153df36532ab40e30912b534c61f222c09dad63fc6097d324b53c265f9284f20c585d3095c")

if("app" IN_LIST FEATURES)
    set(OMPL_DISTNAME "omplapp")
    set(OMPL_CHECKSUM "04812a659fd81c2c541907911cbf4e5987be034546e8e48ed3d11b2b2f9ad3f7931f15d30a32ce3b64deb66b13875970797ac5072e92bfa0841e8d27d85fcb18")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/ompl/ompl/downloads/${OMPL_DISTNAME}-${OMPL_VERSION}-Source.tar.gz"
    FILENAME "${OMPL_DISTNAME}-${OMPL_VERSION}.tar.gz"
    SHA512 ${OMPL_CHECKSUM}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${OMPL_VERSION}
    PATCHES fix-findeigen3.patch
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_REGISTRATION=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DOMPL_BUILD_PYTESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ompl/cmake)

# Remove debug distribution and other, move ompl_benchmark to tools/ dir
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/man
    ${CURRENT_PACKAGES_DIR}/share/ompl/demos
    ${CURRENT_PACKAGES_DIR}/share/ompl/ompl.conf
    ${CURRENT_PACKAGES_DIR}/share/ompl/plannerarena
)
if ("app" IN_LIST FEATURES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/ompl)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ompl_benchmark.exe ${CURRENT_PACKAGES_DIR}/tools/ompl/ompl_benchmark.exe)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/share/ompl/resources
        ${CURRENT_PACKAGES_DIR}/share/ompl/webapp
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
