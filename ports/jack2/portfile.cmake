vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF b54a09bf7ef760d81fdb8544ad10e45575394624 # v1.9.14
    SHA512 a5f920ed1df71d9f5e3c4889ea2aa4d9ed9082d0b9070437a068e24a2caa5dffaa71b19352e9da056e9f23e930edab56816235ceb9293cc33d8870265f392c1d
    HEAD_REF master
)

# Install headers and a statically built JackWeakAPI.c
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/README.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
