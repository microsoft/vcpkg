# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF e0416224a80f1e3d8aff5e102dad59b4b7d78944  #v3.7.1
    SHA512 2f6849a39ebff8a6e202a11beeda68ff7e75a14f7194643b3af3da7cf6916b1f04fa529b120190741919d1b8d43755a11cb8a98657f1dfceae17a5748ff1fdd1
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
file(INSTALL "${SOURCE_PATH}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
