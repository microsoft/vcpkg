if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP build not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF f4e1dfa2dcab88295c7026d5441c3190e3b5f71d
    SHA512 4d5d0118931c273754e5733e825a55adc0be5f09402f27a29486aab28b6e1ecc13230c85eeffc4257eea1236c85c1b06b7382fe116b9f3505a4ac49d81b61f3a
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
