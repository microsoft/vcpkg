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
    REF 70b9ec13427ea68de6f4213e9dfec6129fbab21b
    SHA512 c91fbb9a672257c63ee83b40b62961b89568ca33081048b440876c390a2a2e11c602aaf43a6c9485fd85a91248f34a70d7b9ea769d0cfcd4b35b80d58a6ad737
    HEAD_REF develop
)

# Handle version data here to prevent issues from doing this twice in parallel
set(SLEEPY_DISCORD_VERSION_HASH 70b9ec13427ea68de6f4213e9dfec6129fbab21b)
set(SLEEPY_DISCORD_VERSION_BUILD 949)
set(SLEEPY_DISCORD_VERSION_BRANCH "develop")
set(SLEEPY_DISCORD_VERSION_IS_MASTER 0)
set(SLEEPY_DISCORD_VERSION_DESCRIPTION_CONCAT " ")
set(SLEEPY_DISCORD_VERSION_DESCRIPTION "70b9ec13")
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
