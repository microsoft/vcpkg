vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  d3bda6c7009c6b3241ef2e6c999eff577116dc68 #1.7.0-rc3
    SHA512 6ef135b8c9f7653d3af713f03030b0bd5b833e43224543d8b1e443d76c481a5edcad31297b47e9d4d0b8451e7709948adfcca36deba0255daaf3c2f024ce978a
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
)

vcpkg_install_make()

if (EXISTS ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
    file(COPY ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/contrib/bin/libtool)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/contrib ${CURRENT_PACKAGES_DIR}/debug/contrib)

file(GLOB ${CURRENT_PACKAGES_DIR}/bin LIBMESH_TOOLS)
foreach (LIBMESH_TOOL ${LIBMESH_TOOLS})
    file(COPY ${LIBMESH_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    file(REMOVE ${LIBMESH_TOOL})
endforeach()

file(GLOB LIBMESH_TOOLS ${CURRENT_PACKAGES_DIR}/examples/*)
foreach (LIBMESH_TOOL ${LIBMESH_TOOLS})
    file(COPY ${LIBMESH_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    file(REMOVE ${LIBMESH_TOOL})
endforeach()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Remove tools and debug include directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/contrib ${CURRENT_PACKAGES_DIR}/debug/etc
                    ${CURRENT_PACKAGES_DIR}/debug/examples ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/Make.common ${CURRENT_PACKAGES_DIR}/debug/Make.common)

vcpkg_copy_pdbs()

file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
