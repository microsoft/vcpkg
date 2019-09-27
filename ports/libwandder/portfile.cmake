vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wanduow/libwandder
    REF 1.1.3-1
    SHA512 0174c37910e827223827ee48e564d57fd8a14b694e8c0026b1a8edaafc76d23d2cbc1084087593e3f516d207fd54bf4fc8f6a308fbf7f581e867ea9201ecae1d
    HEAD_REF master
    PATCHES fix-c1083-error.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)