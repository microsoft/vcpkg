include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("msix only supports dynamic library linkage")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "msix only supports dynamic crt linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/msix-packaging
    REF v1.0
    SHA512 11abf60da3414ce59f4347df8b2872ad6aa8a3c1e077f6e0be5c66ce90f14340cec5e58c30fb42ed17a10d5296dc0718bb8cddd665bdc20359bf7f0be4b0b4dc
    HEAD_REF master
)

file(REMOVE_RECURSE ${SOURCE_PATH}/lib)
file(MAKE_DIRECTORY ${SOURCE_PATH}/lib)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/lib)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/install-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DWIN32=ON
        -DINSTALL_LIBMSIX=ON
    OPTIONS_RELEASE
        -DINSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/msix RENAME copyright)

vcpkg_copy_pdbs()

