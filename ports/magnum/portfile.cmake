include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum
    REF c8416ca4c3e9b68ba62acc9f73de235526cb3d6e
    SHA512 d595be48ae44d944d5747880e0108bdc445b92fcc306f0169699e2b80500919647063ac88ef67491b2d8e92ae1f0612cd8768fc63d8cc4ffe4c625988b63504d
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-sdl-includes.patch 
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
        -DWITH_SDL2APPLICATION=ON
        -DWITH_AUDIO=ON
        -DWITH_WAVAUDIOIMPORTER=ON
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
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/magnum)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/magnum/COPYING ${CURRENT_PACKAGES_DIR}/share/magnum/copyright)

vcpkg_copy_pdbs()