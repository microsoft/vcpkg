# When this port is updated, the minizip port should be updated at the same time
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO madler/zlib
    REF v${VERSION}
    SHA512 16fea4df307a68cf0035858abe2fd550250618a97590e202037acd18a666f57afc10f8836cbbd472d54a0e76539d0e558cb26f059d53de52ff90634bbf4f47d4
    HEAD_REF master
    PATCHES
        0001-Prevent-invalid-inclusions-when-HAVE_-is-set-to-0.patch
)

set(CMAKE_CONFIGURE_OPTIONS
    -DZLIB_BUILD_TESTING=OFF
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND CMAKE_CONFIGURE_OPTIONS
        -DZLIB_BUILD_SHARED=OFF
        -DZLIB_BUILD_STATIC=ON
    )
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND CMAKE_CONFIGURE_OPTIONS
        -DZLIB_BUILD_SHARED=ON
        -DZLIB_BUILD_STATIC=OFF
    )
else()
    message(FATAL_ERROR "Unknown VCPKG_LIBRARY_LINKAGE='${VCPKG_LIBRARY_LINKAGE}'")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${CMAKE_CONFIGURE_OPTIONS}
)

vcpkg_cmake_install()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install the pkgconfig file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc" "-lz" "-lzd")
    endif()
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

file(COPY "${CURRENT_PACKAGES_DIR}/lib/cmake/zlib" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/zlib" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 1")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
