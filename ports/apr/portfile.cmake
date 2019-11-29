if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION 1.6.5)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/apr/apr-${VERSION}.tar.bz2"
    FILENAME "apr-${VERSION}.tar.bz2"
    SHA512 d3511e320457b5531f565813e626e7941f6b82864852db6aa03dd298a65dbccdcdc4bd580f5314f8be45d268388edab25efe88cf8340b7d2897a4dbe9d0a41fc
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if("private-headers" IN_LIST FEATURES)
    set(INSTALL_PRIVATE_H ON)
else()
    set(INSTALL_PRIVATE_H OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINSTALL_PDB=OFF
        -DMIN_WINDOWS_VER=Windows7
        -DAPR_HAVE_IPV6=ON
        -DAPR_INSTALL_PRIVATE_H=${INSTALL_PRIVATE_H}
)

vcpkg_install_cmake()

# There is no way to suppress installation of the headers in debug builds.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Both dynamic and static are built, so keep only the one needed
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/apr-1.lib
                ${CURRENT_PACKAGES_DIR}/lib/aprapp-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/apr-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/aprapp-1.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libaprapp-1.lib
                ${CURRENT_PACKAGES_DIR}/debug/lib/libaprapp-1.lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
