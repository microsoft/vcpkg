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
    REF adc4551d835d0b73c631207278d0a2a9038a79a4
    SHA512 d0869f690fde66e2d28cb8de4ede964650c2fbd1fbcc8d3db08671e28ae7b814df79c108abdcc2f4aab4146f4f4a37c17b75f22487ccc9d5607c0c665db94c34
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DSLEEPY_VCPKG=ON -DAUTO_DOWNLOAD_LIBRARY=OFF ${FEATURE_OPTIONS}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
