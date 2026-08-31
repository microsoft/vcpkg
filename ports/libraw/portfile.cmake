vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibRaw/LibRaw
    REF "${VERSION}"
    SHA512 24313fbdc0f91432cf1de9fd1a7af56cc01c314760194a32fed8e7f5b991ff35e34fe04606e40ed86b3982f88e141c54b528d33631b420b71525abb06c95f5f4
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH LIBRAW_CMAKE_SOURCE_PATH
    REPO LibRaw/LibRaw-cmake
    REF eb98e4325aef2ce85d2eb031c2ff18640ca616d3
    SHA512 63e68a4d30286ec3aa97168d46b7a1199268099ae27b61abcc92e93ec30e48d364086227983a1d724415e5f4da44d905422f30192453b95f31040e5f8469c3f9
    HEAD_REF master
    PATCHES
        dependencies.patch
        # Move the non-thread-safe library to manual-link. This is unfortunately needed
        # because otherwise libraries that build on top of libraw have to choose.
        fix-install.patch
)

file(COPY "${LIBRAW_CMAKE_SOURCE_PATH}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${LIBRAW_CMAKE_SOURCE_PATH}/cmake" DESTINATION "${SOURCE_PATH}")


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp      ENABLE_OPENMP
        openmp      CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
        dng-lossy   CMAKE_REQUIRE_FIND_PACKAGE_JPEG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_Jasper=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=1
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_OpenMP
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake")
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libraw.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libraw.pc" "-lraw" "-lrawd")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libraw_r.pc" "-lraw_r" "-lraw_rd")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h"
        "#ifdef LIBRAW_NODLL" "#if 1"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h"
        "#ifdef LIBRAW_NODLL" "#if 0"
    )
endif()

file(COPY "${CURRENT_PACKAGES_DIR}/share/cmake/libraw/FindLibRaw.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/cmake"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYRIGHT"
    "${SOURCE_PATH}/LICENSE.LGPL"
    "${SOURCE_PATH}/LICENSE.CDDL"
)
