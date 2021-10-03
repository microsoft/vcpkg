vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 0.15.2
    SHA512 ae3ea533e57ab3c386ce457dbaa39a256801b7340649d5ff80a51410481e73ab194724744b97d85cb6d111798e45eee594bb22da2f1f3c547fe8e331e0690127
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
