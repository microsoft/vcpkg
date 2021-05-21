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
    REF 52059a39ff0b435724e5c67ef364dcada655a07a
    SHA512 025c91e178136b5a4fd19f2015a540fe2b725f384abf04621429422578117c002cf5f4eea311102c0fe62e09ff937035888124e2ffc4369b71b9f3265fa3aeab
    HEAD_REF develop
)

# Handle version data here to prevent issues from doing this twice in parallel
set(SLEEPY_DISCORD_VERSION_HASH 52059a39ff0b435724e5c67ef364dcada655a07a)
set(SLEEPY_DISCORD_VERSION_BUILD 890)
set(SLEEPY_DISCORD_VERSION_BRANCH "develop")
set(SLEEPY_DISCORD_VERSION_IS_MASTER 0)
set(SLEEPY_DISCORD_VERSION_DESCRIPTION_CONCAT " ")
set(SLEEPY_DISCORD_VERSION_DESCRIPTION "52059a39")
configure_file(
    "${SOURCE_PATH}/include/sleepy_discord/version.h.in"
    "${SOURCE_PATH}/include/sleepy_discord/version.h"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DSLEEPY_VCPKG=ON 
        -DAUTO_DOWNLOAD_LIBRARY=OFF 
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/sleepy_discord/sleepy-discord-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
