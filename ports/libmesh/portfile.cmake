vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  bff2bf14e3fa44a3c2bccea1de8080ebee0c0ad6 #1.7.0-rc2
    SHA512 87fd845ab8c1b9a992810ddace3b38a612ffb7dec6973c2448b5dd2b3bff9a69216df35672e1945a3bc2916e59f80862a7b769396b8bb609f3420b7cc6e52a84
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
