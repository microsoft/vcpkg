if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PATCHES
        0001-windows-build.patch
        0002-windows-build-contrib.patch
        0003-libmesh-export.patch
        0004-netcdf-getopt.patch
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libMesh/libmesh
    REF  21f623c837b3865ed65ec9608b357bdb1935d428 #1.5.0
    SHA512 53ad41ed0cd99cb5096ff338a3ff5d8a8ecbfb17dc1d7ee0d2b0cbffecbede7f7c11b7c3c2233cec9dde0988c8828ba0199247effd3442befc72230e641a185e
    HEAD_REF master
    PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS
        --disable-qhull
        --disable-fparser
        ax_cv_cxx_openmp=none
        ac_cv_c_restrict=restrict
        ac_cv_lib_m_floor=yes
        LIBS=-lgetopt
    )
endif()

set(RELEASE_METHODS "opt")
if("tests" IN_LIST FEATURES)
    string(APPEND RELEASE_METHODS " devel")
endif()

# There a lot of configure options in this port which are not yet correctly handled by VCPKG
# To only mention two:
#  --enable-vtk-required   Error if VTK is not detected by configure
#  --enable-capnp-required Error if Cap'n Proto support is not detected by
# but there are a lot more which need to be checked/fixed
# So this port can only be considered a Work In Progress
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    USE_WRAPPERS
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG --with-methods=dbg
    OPTIONS_RELEASE --with-methods=${RELEASE_METHODS}
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/contrib/metis/config.h" "")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(WRITE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/contrib/metis/config.h" "")
    endif()

    # use our version of "compile" wrapper for *.C compilation as C++ source
    vcpkg_add_to_path(PREPEND "${SOURCE_PATH}/build-aux")
endif()

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

