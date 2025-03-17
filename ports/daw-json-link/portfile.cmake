# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF "v${VERSION}"
    SHA512 1a74a943b06dd9c058ba1be6352da1c2f7b9a3a6fe95f298ad69f72aa092a912c1aa971952e8b123b61f01b3345269f9607675666bf58293cd91023a86431ac3
    HEAD_REF release
)

file(REMOVE "${SOURCE_PATH}/include/daw/daw_tuple_forward.h")
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
