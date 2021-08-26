vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF 3.0.0
    SHA512 42735d73d24546b37332d649a2633f4a1b6e004b016c45d53bd8e230a157753bb319c80a59721865b9c3dcc588b4eec3cdf4ae9f7fc2cdf290b6bb07c866552c
    HEAD_REF master
    PATCHES
        fix-file-not-found.patch
        fix-error-C3321.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
