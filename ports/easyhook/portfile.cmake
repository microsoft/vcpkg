include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
	message(FATAL_ERROR "easyhook only support windows.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EasyHook/EasyHook
    REF v2.7.6789.0
    SHA512 a48b4fe6dd2e55a2d515bc917c0f3ff5b73f08d1778e671df802347c3b8e1d4638005582a494acdf891ffe3fa6eae3eab0096083a8af2352e3f0883eb83421d6
    HEAD_REF master
)
if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(RELEASE_CONFIGURATION netfx3.5-Debug)
else()
    set(DEBUG_CONFIGURATION netfx3.5-Release)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/EasyHookDll.vcxproj DESTINATION ${SOURCE_PATH}/EasyHookDll)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH EasyHook.sln
	TARGET EasyHookDll
    #LICENSE_SUBPATH LICENSE
    RELEASE_CONFIGURATION "netfx3.5-Release"
    DEBUG_CONFIGURATION "netfx3.5-Debug"
	OPTIONS /p:PreprocessorDefinitions="_ALLOW_RTCc_IN_STL"
)

# These libraries are useless, so remove.
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/EasyHook.dll ${CURRENT_PACKAGES_DIR}/bin/EasyHook.pdb)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.dll ${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.pdb)

# Install includes
file(INSTALL ${SOURCE_PATH}/Public DESTINATION ${CURRENT_PACKAGES_DIR}/include/easyhook)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/easyhook RENAME copyright)
