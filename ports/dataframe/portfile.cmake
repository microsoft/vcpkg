include(vcpkg_common_functions)

vcpkg_fail_port_install(MESSAGE "dataframe currently only supports Windows, Linux and Mac platforms" ON_TARGET "WindowsStore")

if(VCPKG_TARGET_IS_WINDOWS)
    set(SOURCE_PATCH fix-cmakelists.patch)
endif()	

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF V-1.5.0
    SHA512 2eaef420d6b6d7eeeb0e78ec7c9e0bb06d21f8a2c6416c641def567d340b2fdd21f7981df65be2da54117b440afbbc8fa4c7e4d106d954e2b5a17d717322dc02
    HEAD_REF master
    PATCHES
        ${SOURCE_PATCH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/dataframe)
elseif(VCPKG_TARGET_IS_LINUX)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/dataframe)
endif()

file(INSTALL ${SOURCE_PATH}/License DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)