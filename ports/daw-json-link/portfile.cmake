vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF 37ecbfe7cd9d0ba660ef77998228c827ab407ff3
    SHA512 0ed32115e0e51fa008c02ada9def131b699332f0765718333c2d02707b985cd5a1f558d63e40e72d290f6a9329946cdde101b2b33d50b04bf54a715efd5c3e40
    HEAD_REF master
    PATCHES thirdparty_and_portname.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DDAW_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

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
