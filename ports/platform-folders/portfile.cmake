include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(TARGET_BUILD_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sago007/PlatformFolders
    REF 4.0.0
    SHA512 89bd9b971cff55ddb051ffcf2e1bbf1678ec14c601916d65ebd4d8e46a79cf93f12cbe9c13ebd0417808f35d7031d13274cda78f009a26fbd19d71e13a5e5ac6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${TARGET_BUILD_PATH}-rel/platform_folders.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
    file(INSTALL ${TARGET_BUILD_PATH}-dbg/platform_folders.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
endif()

if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
	vcpkg_fixup_cmake_targets(CONFIG_PATH cmake/ TARGET_PATH /share/platform_folders)
else()
	vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ TARGET_PATH /share/)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/platform-folders RENAME copyright)

vcpkg_copy_pdbs()
