if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP build not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF 1b8bc985a71143317ae9e4969fa08e164da7c2e5
    SHA512 37f2df9ec195f3d69d9526d0dea6a93ef49d69287bfae6ccd9671477491502ea760ed14e3b206b4f488831ab728dc749847b7d176c9b8439fb58b0a0466fe6c5
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
