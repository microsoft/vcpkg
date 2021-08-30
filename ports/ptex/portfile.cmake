vcpkg_fail_port_install(ON_TARGET "uwp")

set(PTEX_VER 2.3.2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF 1b8bc985a71143317ae9e4969fa08e164da7c2e5
    SHA512 37f2df9ec195f3d69d9526d0dea6a93ef49d69287bfae6ccd9671477491502ea760ed14e3b206b4f488831ab728dc749847b7d176c9b8439fb58b0a0466fe6c5
    HEAD_REF master
    PATCHES 
        fix-build.patch
        fix-config.cmake.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED_LIB ON)
    set(BUILD_STATIC_LIB OFF)
else()
    set(BUILD_SHARED_LIB OFF)
    set(BUILD_STATIC_LIB ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DPTEX_VER=v${PTEX_VER}
        -DPTEX_BUILD_SHARED_LIBS=${BUILD_SHARED_LIB}
        -DPTEX_BUILD_STATIC_LIBS=${BUILD_STATIC_LIB}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Ptex)
vcpkg_copy_pdbs()

foreach(HEADER PtexHalf.h Ptexture.h)
    file(READ "${CURRENT_PACKAGES_DIR}/include/${HEADER}" PTEX_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        string(REPLACE "ifndef PTEX_STATIC" "if 1" PTEX_HEADER "${PTEX_HEADER}")
    else()
        string(REPLACE "ifndef PTEX_STATIC" "if 0" PTEX_HEADER "${PTEX_HEADER}")
    endif()
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/${HEADER}" "${PTEX_HEADER}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/src/doc/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
