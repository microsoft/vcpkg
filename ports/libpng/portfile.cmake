include(vcpkg_common_functions)
set(LIBPNG_VERSION 1.6.29)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libpng-${LIBPNG_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.xz"
    FILENAME "libpng-${LIBPNG_VERSION}.tar.xz"
    SHA512 070393423ec11f19e3264a0200959ae09238aa005615571586987253028b4ffb7e6b7c734a132f65180252b0259f79add03896d79fdc7dcfd8773b82c82a5ffc
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/use-abort-on-all-platforms.patch
        ${CMAKE_CURRENT_LIST_DIR}/dont-double-eval-CMAKE_SYSTEM_PROCESSOR.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PNG_STATIC_LIBS OFF)
    set(PNG_SHARED_LIBS ON)
else()
    set(PNG_STATIC_LIBS ON)
    set(PNG_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPNG_STATIC=${PNG_STATIC_LIBS}
        -DPNG_SHARED=${PNG_SHARED_LIBS}
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpng16_static.lib ${CURRENT_PACKAGES_DIR}/lib/libpng16.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16_staticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libpng16d.lib)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpng ${CURRENT_PACKAGES_DIR}/share/libpng)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpng/libpng16-debug.cmake ${CURRENT_PACKAGES_DIR}/share/libpng/libpng16-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/libpng)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpng/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpng/copyright)

vcpkg_copy_pdbs()
