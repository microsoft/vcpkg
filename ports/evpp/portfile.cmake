set(EVPP_VERSION 0.7.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Qihoo360/evpp
    REF v${EVPP_VERSION}
    SHA512 ddcef8d2af6b3c46473d755c0f0994d63d56240ea85d6b44ceb6b77724c3c56bbf1156f7188e270fb5f9f36f25bfc2f96669d7249a34c921922671e3fe267e88
    HEAD_REF master
    PATCHES
        fix-rapidjson-1-1.patch
        fix-linux-build.patch
        fix-osx-build.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/rapidjson ${SOURCE_PATH}/3rdparty/concurrentqueue)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEVPP_VCPKG_BUILD=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
