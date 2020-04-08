#vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows") 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  21f623c837b3865ed65ec9608b357bdb1935d428 #1.5.0
    SHA512 53ad41ed0cd99cb5096ff338a3ff5d8a8ecbfb17dc1d7ee0d2b0cbffecbede7f7c11b7c3c2233cec9dde0988c8828ba0199247effd3442befc72230e641a185e
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
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

file(INSTALL ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

