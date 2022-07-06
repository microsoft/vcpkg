# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF 76ef0c71a308bf2286b7ac34df4883b14017d02c  #v3.0.0
    SHA512 d416f17af7b9d8adf7a7fafdec6b3f8c17275ca778dc5bc71748c3b705ac248c0a51ae02ae9b6b7a1aecd00d814c44d77849be1784d02476a4aaaa680f9db830
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
