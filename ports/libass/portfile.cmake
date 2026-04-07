vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF ${VERSION}
    SHA512 08762623dd09e3034699ba9d11b70d1f6cc6b2e3b38aa897b07efef1364e76141df484e70ed27888cf3595b77d072cdb5e8abbbfa560e33ca21f87872e24df8d
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
