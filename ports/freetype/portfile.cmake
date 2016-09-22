include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://download.savannah.gnu.org/releases/freetype/freetype-2.6.3.tar.bz2"
    FILENAME "freetype-2.6.3.tar.bz2"
    SHA512 e1f9018835fc88beeb4479537b59f866c52393ae18d24a1e0710a464cf948ab02b35c2c6043bc20c1db3a04871ee4eb0bb1d210550c0ea2780c8b1aea98fbf0d
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freetype-2.6.3
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Support-Windows-DLLs-via-CMAKE_WINDOWS_EXPORT_ALL_SY.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freetype-2.6.3
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/include/freetype2/freetype ${CURRENT_PACKAGES_DIR}/include/freetype2)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/include/freetype2/ft2build.h ${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/freetype ${CURRENT_PACKAGES_DIR}/share/freetype)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/freetype/freetype-config-debug.cmake ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config-debug.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY
    ${CURRENT_BUILDTREES_DIR}/src/freetype-2.6.3/docs/LICENSE.TXT
    ${CURRENT_BUILDTREES_DIR}/src/freetype-2.6.3/docs/FTL.TXT
    ${CURRENT_BUILDTREES_DIR}/src/freetype-2.6.3/docs/GPLv2.TXT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freetype/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/freetype/copyright)
vcpkg_copy_pdbs()

