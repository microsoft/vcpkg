vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibRaw/LibRaw
    REF "${VERSION}"
    SHA512 6cea6d859961d713382a9017107c730c7a8777be85d454bd05f1417a69fda902aa9591151eac5f4bd231ce2a86fc39da56e3a024104101f24d6069197fcabbc7
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH LIBRAW_CMAKE_SOURCE_PATH
    REPO LibRaw/LibRaw-cmake
    REF 6e26c9e73677dc04f9eb236a97c6a4dc225ba7e8
    SHA512 8ce13d37c2ace2fbc57f571052a5a5a847b707b3de1b3b9e0c1a46afaca86cabd42ee275600eeadc3127bc2a0d0a4f224caed0b07feffdafea32ad0f42e50379
    HEAD_REF master
    PATCHES
        dependencies.patch
        install-interface.patch
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
