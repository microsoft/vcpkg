vcpkg_from_github(
OUT_SOURCE_PATH SOURCE_PATH
ORG             Ai-finder-for-api
REPO            easy-vulkan-gui
REF             v0.0.7
SHA512          400889a2b61701a90ab837740a08c79ff1c28c0b8cf1ddfeb9381048d9b1612d4cb0747795b3d154e86ef6b898871dcc7d396f808d6f5f0f87eb6a6a828cc2cc
HEAD_REF        main
) 

vcpkg_cmake_configure(
SOURCE_PATH "${SOURCE_PATH}"
OPTIONS
-DVGUI_BUILD_EXAMPLES=OFF
-DVGUI_BUILD_TESTS=OFF
) 

vcpkg_cmake_install() 

vcpkg_cmake_config_fixup(
CONFIG_PATH lib/cmake/vgui
) 

### Remove debug includes (duplicate of release)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") 

### Install license

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")vcpkg_from_github(
OUT_SOURCE_PATH SOURCE_PATH
ORG             Ai-finder-for-api
REPO            easy-vulkan-gui
REF             v0.0.7
SHA512          400889a2b61701a90ab837740a08c79ff1c28c0b8cf1ddfeb9381048d9b1612d4cb0747795b3d154e86ef6b898871dcc7d396f808d6f5f0f87eb6a6a828cc2cc
HEAD_REF        main
) 

vcpkg_cmake_configure(
SOURCE_PATH "${SOURCE_PATH}"
OPTIONS
-DVGUI_BUILD_EXAMPLES=OFF
-DVGUI_BUILD_TESTS=OFF
) 

vcpkg_cmake_install() 

vcpkg_cmake_config_fixup(
CONFIG_PATH lib/cmake/vgui
) 

### Remove debug includes (duplicate of release)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") 

### Install license

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")vcpkg_from_github(
OUT_SOURCE_PATH SOURCE_PATH
ORG             Ai-finder-for-api
REPO            easy-vulkan-gui
REF             v0.0.7
SHA512          400889a2b61701a90ab837740a08c79ff1c28c0b8cf1ddfeb9381048d9b1612d4cb0747795b3d154e86ef6b898871dcc7d396f808d6f5f0f87eb6a6a828cc2cc
HEAD_REF        main
) 

vcpkg_cmake_configure(
SOURCE_PATH "${SOURCE_PATH}"
OPTIONS
-DVGUI_BUILD_EXAMPLES=OFF
-DVGUI_BUILD_TESTS=OFF
) 

vcpkg_cmake_install() 

vcpkg_cmake_config_fixup(
CONFIG_PATH lib/cmake/vgui
) 

### Remove debug includes (duplicate of release)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") 

### Install license

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")