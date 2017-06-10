include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-plugins
    REF 645b50647d5164c5ec8f5bc83ba2578f6cfe7d80
    SHA512 73c7fb7e9a5a9e2a4ee7314b5d41d98ada9cf1a50c1cd833c2ae19c5bdab66862f3696f142e987f9d2b551142e94f96a2d8ccad37625682c8391400091dcf879
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-fix-include.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC 1)
else()
    set(BUILD_STATIC 0)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DWITH_STBIMAGECONVERTER=ON
        -DWITH_STBIMAGEIMPORTER=ON
        -DWITH_STBTRUETYPEFONT=ON
        -DWITH_STBTRUETYPEFONT=ON
        -DWITH_MINIEXRIMAGECONVERTER=ON
        -DWITH_OPENGEXIMPORTER=ON
        -DWITH_OPENGEXIMPORTER=ON
        -DWITH_STANFORDIMPORTER=ON
        -DWITH_DRWAVAUDIOIMPORTER=ON
        -DWITH_ANYAUDIOIMPORTER=ON
        -DWITH_ANYIMAGECONVERTER=ON
        -DWITH_ANYSCENEIMPORTER=ON
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/magnum-plugins)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/COPYING ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/copyright)

vcpkg_copy_pdbs()