vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "websocketpp"    USE_WEBSOCKETPP
    "websocketpp"    USE_BOOST_ASIO
    "cpr"            USE_CPR
    "voice"          ENABLE_VOICE
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF 2cc4f007e6282b6a8fb6d83a400332976606e3e7
    SHA512 6c0d353bb42f4f347e07ca0eca2741def4a79a2af702cf6c45833c7a4ef08ef21597ffb79d622de0747e90a1db24e75962575a6a72701909f9923258371ec78a
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DSLEEPY_VCPKG=ON -DAUTO_DOWNLOAD_LIBRARY=OFF ${FEATURE_OPTIONS}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
