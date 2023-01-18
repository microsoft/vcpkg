vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF "v${VERSION}"
    SHA512 080f5f94227e63ae075fabb92a897d0cbcbcd60fa54192936b85c8ad25620ad1c37b8767eb69e470fccdd9573c47f48c7402172c23f516befd13e1382b4e6819
    HEAD_REF master
    PATCHES
        disable-symlink.patch
        fix-find-package-asio.patch
        pdb-file.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME fastrtps CONFIG_PATH "share/fastrtps/cmake")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(SHELL_SUFFIX ".bat")
endif()
foreach(TOOL    "fastdds${SHELL_SUFFIX}"
                "ros-discovery${SHELL_SUFFIX}")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds${SHELL_SUFFIX}" "$dir/../tools/fastdds/fastdds.py" "$dir/fastdds.py")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery${SHELL_SUFFIX}" "$dir/../tools/fastdds/fastdds.py" "$dir/fastdds.py")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/discovery/parser.py" "tool_path / '../../../bin'" "tool_path / '..'")

vcpkg_copy_tools(TOOL_NAMES fast-discovery-server fast-discovery-server-1.0.1 AUTO_CLEAN)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
