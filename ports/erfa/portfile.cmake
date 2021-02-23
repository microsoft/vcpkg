
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liberfa/erfa
    REF v1.7.2
    SHA512 ae1bc8e7b4d9f53f513c97fc1adbc65fce68917d91200007adefde77b134ec95cf8756e4c19bc9061b02767f70654bc1645bbee8c1df2bf36c121323e24b19b7
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/erfa/copyright" COPYONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/erfaConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
#file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
# file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libogg RENAME copyright)