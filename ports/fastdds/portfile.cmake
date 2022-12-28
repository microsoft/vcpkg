vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF v2.9.0
    SHA512 080f5f94227e63ae075fabb92a897d0cbcbcd60fa54192936b85c8ad25620ad1c37b8767eb69e470fccdd9573c47f48c7402172c23f516befd13e1382b4e6819
    HEAD_REF master
    PATCHES
        fix-find-package-asio.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    set(SHELL_SUFFIX ".bat")
endif()
foreach(TOOL    "fastdds${SHELL_SUFFIX}"
                "ros-discovery${SHELL_SUFFIX}")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds${SHELL_SUFFIX}" "$dir/../tools/fastdds/fastdds.py" "$dir/fastdds.py")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery${SHELL_SUFFIX}" "$dir/../tools/fastdds/fastdds.py" "$dir/fastdds.py")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/discovery/parser.py" "tool_path / '../../../bin'" "tool_path / '..'")

vcpkg_copy_tools(TOOL_NAMES fast-discovery-server AUTO_CLEAN)
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_copy_tools(TOOL_NAMES fast-discovery-server-1.0.1 AUTO_CLEAN)
endif()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/fast-discovery-serverd-1.0.1${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
