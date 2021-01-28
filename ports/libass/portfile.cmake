vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 0.15.0
    SHA512 a832da5246577cf815481bb9e4bebabc74bc1d0f5c50faa098f4150a379d801d7e6d1bd7f9f578143a9412e258c5296d08c4fc2d04cc33f1751e613c2583214c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass.def DESTINATION ${SOURCE_PATH})

# Since libass uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(COPY ${SOURCE_PATH}/libass/ass.h ${SOURCE_PATH}/libass/ass_types.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/ass)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
