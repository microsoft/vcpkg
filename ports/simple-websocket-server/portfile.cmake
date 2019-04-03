include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eidheim/Simple-WebSocket-Server
    REF a0ec222a5a6f74160ae5049aaa2a93b3f44c0b58
    SHA512 94e4c01ba30fdfc107d1c5015db487a13b3aa8dbe8ee7522cf273f7678a723c63f018a0062c193a8431f4f466ba7c16ab1ae5efe46f6b579320e8f9339b3e074
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