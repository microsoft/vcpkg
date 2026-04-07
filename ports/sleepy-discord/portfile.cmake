vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cpr"            USE_CPR
        "voice"          ENABLE_VOICE
        "compression"    USE_ZLIB
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF 13455925f9e122c8898c6d6407e9ff7624dd0a17
    SHA512 ebb5d7e5b517fd03554dfeecfb369c33544dce2605e4bb73512dd5b12ff4a393dfa7d19e7002b129841b6b7bb3eab404cfee1d3b58a08e3b591a2625ddc708d6
    HEAD_REF master
    PATCHES
        fix-messing-header.patch
)

# Handle version data here to prevent issues from doing this twice in parallel
set(SLEEPY_DISCORD_VERSION_HASH ae26f3f573f625bc32561776126b4b06707d985c)
set(SLEEPY_DISCORD_VERSION_BUILD 1017)
set(SLEEPY_DISCORD_VERSION_BRANCH "master")
set(SLEEPY_DISCORD_VERSION_IS_MASTER 1)
set(SLEEPY_DISCORD_VERSION_DESCRIPTION_CONCAT " ")
set(SLEEPY_DISCORD_VERSION_DESCRIPTION "ae26f3f")
configure_file(
    "${SOURCE_PATH}/include/sleepy_discord/version.h.in"
    "${SOURCE_PATH}/include/sleepy_discord/version.h"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DSLEEPY_VCPKG=ON 
        -DAUTO_DOWNLOAD_LIBRARY=OFF
        -DUSE_ASIO=OFF # ASIO standalone off
        -DUSE_BOOST_ASIO=ON
        -DCMAKE_CXX_STANDARD=17
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sleepy-discord)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
