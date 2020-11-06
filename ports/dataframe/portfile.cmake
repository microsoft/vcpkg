vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF 106fb398a3a05a9d4055a1b00d1e3b9b26a72fa1
    SHA512 43bd888312e16866f399e47adf7d0dc4fb4fd961063d3f53df4a69fb69f1ec95a1c294a4cefc4135f1acf6a4f27715fdcc71cb4bf69f2f72557290d9af439774
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTING:BOOL=OFF
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/dataframe)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/DataFrame TARGET_PATH share/dataframe)

endif()
vcpkg_fixup_pkgconfig()

file( REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

file( INSTALL
    ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
