# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF "v${VERSION}"
    SHA512 121604338153f71dbcf8a8c498997ce46dbce7d3981e4eaad6dd6d6c258fbdccc2d5fda86f0d87f0c824037072775292ec53ecf4cbb483525cf85682bd6e4ba0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDAW_USE_PACKAGE_MANAGEMENT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Append the json-link and dragonbox license information into a single 
# copyright file (they are both Boost v1.0 but it is good to be clear).
file(APPEND "${SOURCE_PATH}/copyright" [=[+----------------------------------------------------------------------------+
|                            json-link copywrite                             |
+----------------------------------------------------------------------------+
]=])
file(READ "${SOURCE_PATH}/LICENSE" json_link_copywrite)
file(APPEND "${SOURCE_PATH}/copyright" ${json_link_copywrite})
file(APPEND "${SOURCE_PATH}/copyright" [=[


+----------------------------------------------------------------------------+
|                            dragonbox copywrite                             |
+----------------------------------------------------------------------------+
]=])

file(READ "${SOURCE_PATH}/LICENSE_Dragonbox" dragonbox_copywrite)
file(APPEND "${SOURCE_PATH}/copyright" ${dragonbox_copywrite})
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/copyright")
