include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/CascLib
    REF 1.50
    SHA512 7e95e314f09e504566e6fa2b1742f986d17526fb0283af8ffb77681338c9a852d369cbd863512a20ddd3a277d10a9bf701d745f500a717826dd08e201eb6d80e
    HEAD_REF master
    PATCHES
        ctype_for_mac.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/casclib RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)