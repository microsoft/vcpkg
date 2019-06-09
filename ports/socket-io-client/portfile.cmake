include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF 1.6.1
    SHA512 01c9c172e58a16b25af07c6bde593507792726aca28a9b202ed9531d51cd7e77c7e7d536102e50265d66de96e9708616075902dfdcfc72983758755381bad707
    HEAD_REF master
    PATCHES fix-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/socket-io-client/copyright COPYONLY)
