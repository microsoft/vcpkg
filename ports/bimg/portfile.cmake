
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bkaradzic/bimg"
    REF f27d884d8974d7d3b9459bae3ec23c667d8c16f8
    SHA512 f5d6f0ac35ee0a3e232d7b374634fbbbd47d808756c44f40b228b703f9069820beb76dfc22dd817dd83cf129ff4b6efd3f1fa77bedd8513422016a5f007da128
    HEAD_REF master
    PATCHES
        10-squish-include.patch
        20-tinyexr-include.patch
        30-stb-include.patch
        40-lodepng-include.patch
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/")

# remove all 3rdparty libraries provided by vcpkg
# because the upstream project requires the `3rdparty` directory to be added to the include path
file(REMOVE_RECURSE
    "${SOURCE_PATH}/3rdparty/libsquish"
    "${SOURCE_PATH}/3rdparty/lodepng"
    "${SOURCE_PATH}/3rdparty/stb"
    "${SOURCE_PATH}/3rdparty/tinyexr"
)
# 3rdparty dependencies currently not provided via vcpkg
#   * astc          -- https://github.com/andrewwillmott/astc-encoder
#   * astc-codec    -- https://github.com/google/astc-codec
#   * edtaa3        -- https://github.com/OpenGLInsights/OpenGLInsightsCode/tree/master/Chapter%2012%202D%20Shape%20Rendering%20by%20Distance%20Fields/makedist
#   * etc1          -- fork of the AOSP project ETC1 codec
#   * etc2          -- unknown source; defines symbols like `::g_table`, high likelyhood of ODR violations
#   * iqa           -- https://sourceforge.net/projects/iqa or https://github.com/tjdistler/iqa
#   * nvtt          -- has a vcpkg port which needs to be thoroughly refactored (conflicts with libsquish and others)
#   * pvrtc         -- https://bitbucket.org/jthlim/pvrtccompressor/

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS_DEBUG -DBIMG_DISABLE_HEADER_INSTALL=1
    OPTIONS_RELEASE -DBIMG_INSTALL_TOOLING=1
)

vcpkg_install_cmake()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_fixup_cmake_targets()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
