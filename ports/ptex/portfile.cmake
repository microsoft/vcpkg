vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF "v${VERSION}"
    SHA512 3b9607b7803e7c857bb00a6d4d8bbe108810c622a3593fb5d655183f3e6689f274ee5e79bcaab6928de38daf05cf25eb56125f39477f134131a8ad45071551b3
    HEAD_REF master
    PATCHES
        fix-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DPTEX_VER=v${VERSION}"
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
