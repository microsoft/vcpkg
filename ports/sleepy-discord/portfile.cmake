vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "websocketpp"    USE_WEBSOCKETPP
        "cpr"            USE_CPR
        "voice"          ENABLE_VOICE
        "compression"    USE_ZLIB
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF 53e68d6a569ab6da17b74279e308bf94919db933
    SHA512 1ee6de7aa70f3d7fc6ec0e21f5e65c6a868c23a29b4f26f614b59bbce3425c1305ce192562bf287d40f98060301b8638bc4bef95789fe8594ce5809adb6dc1e5
    HEAD_REF develop
    PATCHES
        fix-boost.patch
)

# Handle version data here to prevent issues from doing this twice in parallel
set(SLEEPY_DISCORD_VERSION_HASH 53e68d6a569ab6da17b74279e308bf94919db933)
set(SLEEPY_DISCORD_VERSION_BUILD 908)
set(SLEEPY_DISCORD_VERSION_BRANCH "develop")
set(SLEEPY_DISCORD_VERSION_IS_MASTER 0)
set(SLEEPY_DISCORD_VERSION_DESCRIPTION_CONCAT " ")
set(SLEEPY_DISCORD_VERSION_DESCRIPTION "53e68d6")
configure_file(
    "${SOURCE_PATH}/include/sleepy_discord/version.h.in"
    "${SOURCE_PATH}/include/sleepy_discord/version.h"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DSLEEPY_VCPKG=ON 
        -DAUTO_DOWNLOAD_LIBRARY=OFF 
        -DUSE_BOOST_ASIO=ON
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sleepy-discord)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
