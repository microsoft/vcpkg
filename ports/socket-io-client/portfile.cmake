include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO socketio/socket.io-client-cpp
    REF 1.6.1
    SHA512 01c9c172e58a16b25af07c6bde593507792726aca28a9b202ed9531d51cd7e77c7e7d536102e50265d66de96e9708616075902dfdcfc72983758755381bad707
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY           ${SOURCE_PATH}/build/include
     DESTINATION    ${CURRENT_PACKAGES_DIR}/include
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/socket-io-client/copyright COPYONLY)
