vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libMesh/libmesh/releases/download/v${VERSION}/libmesh-${VERSION}.tar.gz"
    FILENAME "libmesh-${VERSION}.tar.gz"
    SHA512 03b2357b693a6791aedb17bb6126d15453dcdfbb0afb31b43f12c7678546e30a2a2281a25cf5cdc118a417b952e4cef6fb84582faf609ec37050fc1bfa17c124
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_from_github(
    OUT_SOURCE_PATH TIMPI_SOURCE_PATH
    REPO libMesh/TIMPI
    REF  9b7bf889257ed4fa56488b29d1d436b1b54671f8
    SHA512 70a306c0c5cd72c2f2f5f7f7086e503c6d95b28e865ba2cd8a871b1a4d3cf1f42f676baf56c014660c434f8b2172b676518e595881e199d8f0fd7c96254fdacf
    HEAD_REF master
)

file(COPY "${TIMPI_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/contrib/timpi")

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --disable-qhull )
endif()

# There a lot of configure options in this port which are not yet correctly handled by VCPKG
# To only mention two:
#  --enable-vtk-required   Error if VTK is not detected by configure
	@@ -25,14 +39,14 @@ vcpkg_configure_make(
vcpkg_install_make()

if (EXISTS ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
    file(COPY ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/contrib)

file(GLOB LIBMESH_EXAMPLES ${CURRENT_PACKAGES_DIR}/examples/*)
foreach (LIBMESH_EXAMPLE ${LIBMESH_EXAMPLES})
    file(COPY ${LIBMESH_EXAMPLE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endforeach()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/examples)

	@@ -46,8 +60,10 @@ file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/contrib ${CURRENT_PACKAGES_DIR
                    ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/tools/libmesh/debug
                    ${CURRENT_PACKAGES_DIR}/Make.common ${CURRENT_PACKAGES_DIR}/debug/Make.common)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")