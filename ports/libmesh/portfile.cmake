vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  21f623c837b3865ed65ec9608b357bdb1935d428 #1.5.0
    SHA512 53ad41ed0cd99cb5096ff338a3ff5d8a8ecbfb17dc1d7ee0d2b0cbffecbede7f7c11b7c3c2233cec9dde0988c8828ba0199247effd3442befc72230e641a185e
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS --disable-qhull )
endif()
# There a lot of configure options in this port which are not yet correctly handled by VCPKG
# To only mention two:
#  --enable-vtk-required   Error if VTK is not detected by configure
#  --enable-capnp-required Error if Cap'n Proto support is not detected by
# but there are a lot more which need to be checked/fixed
# So this port can only be considered a Work In Progress
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG --with-methods=dbg
    OPTIONS_RELEASE --with-methods=opt
)

vcpkg_install_make()

file(RENAME "${CURRENT_PACKAGES_DIR}/examples" "${CURRENT_PACKAGES_DIR}/share/${PORT}/examples")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Remove tools and debug include directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/contrib" "${CURRENT_PACKAGES_DIR}/debug/contrib"
                    "${CURRENT_PACKAGES_DIR}/etc" "${CURRENT_PACKAGES_DIR}/debug/etc"
                    "${CURRENT_PACKAGES_DIR}/debug/examples" "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/tools/libmesh/debug"
                    "${CURRENT_PACKAGES_DIR}/Make.common" "${CURRENT_PACKAGES_DIR}/debug/Make.common")

file(GLOB config_files "${CURRENT_PACKAGES_DIR}/bin/*-config" "${CURRENT_PACKAGES_DIR}/debug/bin/*-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/*-config")
file(REMOVE_RECURSE ${config_files})

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libmesh/libmesh_config.h" "${CURRENT_INSTALLED_DIR}" "")

vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")
