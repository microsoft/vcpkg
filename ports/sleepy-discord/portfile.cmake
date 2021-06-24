vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "websocketpp"    USE_WEBSOCKETPP
        "websocketpp"    USE_BOOST_ASIO
        "cpr"            USE_CPR
        "voice"          ENABLE_VOICE
        "compression"    USE_ZLIB
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF 1d818e1084b85e56b8ab99852f79b974d615c66d
    SHA512 b137ba378c00d476d1bb725c9d52801b5e0114f96743f842b7b8332ed2050185dd49a58efff233c91217abb1e31b8a35d37f8a45f6497d96953bbb38c77ea202
    HEAD_REF develop
)

# Handle version data here to prevent issues from doing this twice in parallel
set(SLEEPY_DISCORD_VERSION_HASH 1d818e1084b85e56b8ab99852f79b974d615c66d)
set(SLEEPY_DISCORD_VERSION_BUILD 905)
set(SLEEPY_DISCORD_VERSION_BRANCH "develop")
set(SLEEPY_DISCORD_VERSION_IS_MASTER 0)
set(SLEEPY_DISCORD_VERSION_DESCRIPTION_CONCAT " ")
set(SLEEPY_DISCORD_VERSION_DESCRIPTION "1d818e1")
configure_file(
    "${SOURCE_PATH}/include/sleepy_discord/version.h.in"
    "${SOURCE_PATH}/include/sleepy_discord/version.h"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DSLEEPY_VCPKG=ON 
        -DAUTO_DOWNLOAD_LIBRARY=OFF 
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sleepy-discord)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
