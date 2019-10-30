vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF 37250ff470277f9947fbf3ba738f943053e30525 # v1.9.13
    SHA512 88f467ca0c968c386b32caaf22899075173828131b507f5cde4b5cb263e58456bd197ea871346fb7def85c62c9e2482b92e3f120966110d8cd203ca60402e68b
    HEAD_REF master
)

# Install headers and a statically built JackWeakAPI.c
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/windows/Setup/src/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jack2 RENAME copyright)
