include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eidheim/Simple-WebSocket-Server
    REF 117e09e29313b814bc0a070ab5fefe4e76a019e5
    SHA512 a33090e9151835bcef3ad48aa5d6a8b564d65bd5a1e8a1adb52133d3d48a41a2fe750a90253e75a2f87c0843df935a6dec3784a7a60583e485c36b6a4d689fc3
    HEAD_REF master
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