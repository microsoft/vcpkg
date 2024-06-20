vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF ${VERSION}
    SHA512 a3e6d514c618a3d2a78287060a6de8002d926b606805a9306f41b902b382f221eff5a7276516c9b4dbe48fa2462936ec7a99585b2615fd44c6564c121ec4cb62
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass.def DESTINATION ${SOURCE_PATH})

# Since libass uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(COPY ${SOURCE_PATH}/libass/ass.h ${SOURCE_PATH}/libass/ass_types.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/ass)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_EXE_PATH ${PKGCONFIG} DIRECTORY)
vcpkg_add_to_path(${PKGCONFIG_EXE_PATH})

vcpkg_cmake_configure(
    OPTIONS -DLIBASS_VERSION=${VERSION}
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
