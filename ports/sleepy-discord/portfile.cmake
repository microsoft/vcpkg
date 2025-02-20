vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cpr"            USE_CPR
        "voice"          ENABLE_VOICE
        "compression"    USE_ZLIB
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF ae26f3f573f625bc32561776126b4b06707d985c
    SHA512 68ba8d9a1e48a9cd0374b0a3ec1ae05da54bf3238b1551726c6d5b99e368a995b86a13c7067cd017cdda7eb85085300d19d84f0e7d8a31df5df5f129d6fff904
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
