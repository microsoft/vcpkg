if (NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_fail_port_install(MESSAGE "${PORT} is only for workflow on Unix-like systems" ON_TARGET "Windows")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/workflow
    REF 7689fdf2137e7d34f0a9f02eae0fc878acf483a2
    SHA512 721f7e1fa666031b552a58c9bd6525afb7113c23022016bfe0713053b535bdc972b6bc81baceb91929216fdc2ecb3150eb693b75fcf27ba991d5df11f88670cd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
