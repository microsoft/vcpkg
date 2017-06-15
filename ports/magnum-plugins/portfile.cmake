include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-plugins
    REF 34a3bc34335ca05097e735db19fe1fae81dbfbb5
    SHA512 918c3eeae246d1ac67e3595c50ff599872a0c1498e9a8a0386ad656f3d9d2209b048b53c25f198660e15201147795578c5c931b00116da46fd77d8e91c0826cb
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/001-tools-path.patch
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