include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF dd6f5e93ee4ebdd9a1974eec7d997991da878b29#v0.139.0
    SHA512 25e098c8ff622e7728a3590595b6484ee7ddd4896a17954190d671711afa56c4d01ff81ac61cf2889e6b3ff005fa38da4055dce3c90fddfb36ff550d98a6fe8f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncons)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncons/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncons/copyright)
