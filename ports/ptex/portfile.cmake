vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wdas/ptex
    REF "v${VERSION}"
    SHA512 26265899d3bb47eca67052d69b08efb89a01cf06a01a4aabdd8118e0497aac87319317450719ac56ea676bbb2ea771bd9b8fe73bc41caa8a2a6818cbc3d83bea
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-android.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        "-DPTEX_VER=v${VERSION}"
        -DPTEX_BUILD_SHARED_LIBS=${BUILD_SHARED_LIB}
        -DPTEX_BUILD_STATIC_LIBS=${BUILD_STATIC_LIB}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ptex )
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/ptex.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ptex.pc")
if(NOT VCPKG_BUILD_TYPE)
  file(COPY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ptex.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/")
endif()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

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
