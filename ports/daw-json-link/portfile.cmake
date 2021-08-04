# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF d8cb3a25a545b27b6ab5e68f4480b92ad0dc78fe
    SHA512 19f486c6782f6134db0f7c8a1a4031b69aeae7f64846f186bccfa37927c8a688545fe5825de841e5ec5408267922b0334db3727d00fcb96b1a36eee81a05eae9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DDAW_USE_PACKAGE_MANAGEMENT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Append the json-link and dragonbox license information into a single 
# copyright file (they are both Boost v1.0 but it is good to be clear).
file(APPEND ${SOURCE_PATH}/copyright [=[+----------------------------------------------------------------------------+
|                            json-link copywrite                             |
+----------------------------------------------------------------------------+
]=])
file(READ ${SOURCE_PATH}/LICENSE json_link_copywrite)
file(APPEND ${SOURCE_PATH}/copyright ${json_link_copywrite})
file(APPEND ${SOURCE_PATH}/copyright [=[


+----------------------------------------------------------------------------+
|                            dragonbox copywrite                             |
+----------------------------------------------------------------------------+
]=])

file(READ ${SOURCE_PATH}/LICENSE_Dragonbox dragonbox_copywrite)
file(APPEND ${SOURCE_PATH}/copyright ${dragonbox_copywrite})
file(INSTALL ${SOURCE_PATH}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
