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
    REF dd9d186ec78fd092292f00f0f42008191b4d3f59
    SHA512 c8d3e3d390525b8bc88d7c195d8bf3c2c7fd806234f7e56ef231f760b1d8731cc2747c0bc43bda23a99c98682da489ca0ec2750c47cd82bffb5fa3a4a2866777
    HEAD_REF develop
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

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
