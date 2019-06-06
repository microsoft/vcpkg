include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF v1.9.12
    SHA512 f0271dfc8f8e2f2489ca52f431ad4fa420665816d6c67a01a76da1d4b5ae91f6dad8c4e3309ec5e0c159c9d312ed56021ab323d74bce828ace26f1b8d477ddfa
    HEAD_REF master
)

# Install headers and a statically built JackWeakAPI.c
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/jack2 RENAME copyright)
