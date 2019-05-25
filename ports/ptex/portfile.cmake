if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP build not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF f4e1dfa2dcab88295c7026d5441c3190e3b5f71d
    SHA512 dbc557dc5e1761204ee3483af9bf4ff1504cbd7955e0405dc27a51f7182e2445e41db086b2792c2491aa2cbaddc74e523170a4b3d25e44d332123d5b7081f4b9
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
