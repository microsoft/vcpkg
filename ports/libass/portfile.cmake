vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libass/libass
    REF 0.16.0
    SHA512 fea93b36d05cd69a5920b603951dd63f46b2434e0dcbb12414bf6e1e584bacc2743fbfc03682d0a672bbfe9bcc057452a942f9967d95a30e535bd3694e40fc7d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libass.def DESTINATION ${SOURCE_PATH})

# Since libass uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

file(COPY ${SOURCE_PATH}/libass/ass.h ${SOURCE_PATH}/libass/ass_types.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/ass)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
