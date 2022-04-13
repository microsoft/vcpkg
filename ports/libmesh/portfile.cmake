vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  e98f7419bd062d4c6b3cc3727899e892915af730 #1.6.2
    SHA512 f70722e92c0928ece2bb8750922d129b775790365a3911b97cc1e89930321d93d491e5992ad5453fc5de87d4c2f8799eb082d08e1ad1b844d81bc60c6435f0dd
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH TIMPI_SOURCE_PATH
    REPO libMesh/TIMPI
    REF  2397962a0b2c4d19c53b1a45f0304eaea999e024
    SHA512 b81c0b8ac03650c4de66e49355249100ccec47938cde11abd26535e0b6f2d35630f09b2510f041dc3104dffcb210f08790db870a04f8d0b02601c9d9d5e0c757
    HEAD_REF master
)

file(COPY "${TIMPI_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/contrib/timpi")

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
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG --with-methods=dbg
    OPTIONS_RELEASE --with-methods=opt
)

vcpkg_install_make()

if (EXISTS ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
    file(COPY ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/contrib)

file(GLOB LIBMESH_EXAMPLES ${CURRENT_PACKAGES_DIR}/examples/*)
foreach (LIBMESH_EXAMPLE ${LIBMESH_EXAMPLES})
    file(COPY ${LIBMESH_EXAMPLE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endforeach()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/examples)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Remove tools and debug include directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/contrib ${CURRENT_PACKAGES_DIR}/debug/etc
                    ${CURRENT_PACKAGES_DIR}/debug/examples ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/tools/libmesh/debug
                    ${CURRENT_PACKAGES_DIR}/Make.common ${CURRENT_PACKAGES_DIR}/debug/Make.common)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
