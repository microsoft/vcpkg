if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP build not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF v2.1.28
    SHA512 ddce3c79f14d196e550c1e8a5b371482f88190cd667a2e2aa84601de1639f7cabb8571c1b3a49b48df46ce550d27088a00a67b1403c3bfec2ed73437c3dca3e8
    HEAD_REF master)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-build.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

foreach(HEADER PtexHalf.h Ptexture.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/${HEADER} PTEX_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        string(REPLACE "ifndef PTEX_STATIC" "if 1" PTEX_HEADER "${PTEX_HEADER}")
    else()
        string(REPLACE "ifndef PTEX_STATIC" "if 0" PTEX_HEADER "${PTEX_HEADER}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/${HEADER} "${PTEX_HEADER}")
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/src/doc/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ptex)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ptex/license.txt ${CURRENT_PACKAGES_DIR}/share/ptex/copyright)
