# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF "v${VERSION}"
    SHA512 710dcc677414d9e4e748276cd43344e403fc664ad67b7a47d032b68a7b21c7a89b0e3ef5cea650ab9a5f3b7148f482aa2fc1152b9fe31d67efaac152bd7a9cd8
    HEAD_REF release
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
