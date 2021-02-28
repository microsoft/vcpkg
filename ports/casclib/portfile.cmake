vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/CascLib
    REF 1.50b
    SHA512 f32cc592f454db4815c0dfd18a9c0076d85b1582e6974d241d1d4094269c42a978fa42186504988ced2c8f4a0b598f41e3ec8a95ddc3c0551af997e37708b1f5
    HEAD_REF master
    PATCHES
        ctype_for_mac.patch
)

file(COPY 
        ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt 
        ${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in
    DESTINATION 
        ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/casclib 
     RENAME copyright)
