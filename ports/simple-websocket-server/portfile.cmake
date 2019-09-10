include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eidheim/Simple-WebSocket-Server
    REF a4d0d06460f9b16edbfa87fac2862d9941824aaa
    SHA512 57d8e207d29c91074e8829e1995be63790a30e672bcaeaaa7266dd3a4035a08bb236caff2ed3b6c7d7dbef578c7ea921e27f158c62cb1e8a8e80123dadba8b74
    HEAD_REF master
    PATCHES
        "client.patch"
        "server.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_STANDALONE_ASIO:BOOL=ON
)
vcpkg_install_cmake()

# Remove duplicate includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/simple-websocket-server)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/simple-websocket-server/LICENSE ${CURRENT_PACKAGES_DIR}/share/simple-websocket-server/copyright)