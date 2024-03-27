vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF "v${VERSION}"
    SHA512 830cf30b0637c30ee30a5a3771346e6f3337ada2972959846b7aa1bec97ccb1e29ef544fe0eb9c324ea02b937ca78fc45f693ca56be8b585ff9d6a29efe6e7ba
    HEAD_REF master
    PATCHES
        fix-find-package-asio.patch
        disable-symlink.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/fastrtps/cmake)

if(VCPKG_TARGET_IS_WINDOWS)
    # copy tools from "bin" to "tools" folder
    foreach(TOOL "fast-discovery-server-1.0.1.exe" "fast-discovery-server.bat" "fastdds.bat" "ros-discovery.bat")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
    endforeach()

    # remove tools from debug builds
    foreach(TOOL "fast-discovery-serverd-1.0.1.exe" "fast-discovery-server.bat" "fastdds.bat" "ros-discovery.bat")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
        endif()
    endforeach()

    # adjust paths in batch files
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds.bat" "%dir%\\..\\tools\\fastdds\\fastdds.py" "%dir%\\..\\fastdds\\fastdds.py")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery.bat" "%dir%\\..\\tools\\fastdds\\fastdds.py" "%dir%\\..\\fastdds\\fastdds.py")

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
elseif(VCPKG_TARGET_IS_LINUX)
    # copy tools from "bin" to "tools" folder
    foreach(TOOL "fast-discovery-server-1.0.1" "fast-discovery-server" "fastdds" "ros-discovery")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
    endforeach()

    # replace symlink by a copy because symlinks do not work well together with vcpkg binary caching
    file(REMOVE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fast-discovery-server")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fast-discovery-server-1.0.1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}" RENAME "fast-discovery-server")

    # remove tools from debug builds
    foreach(TOOL "fast-discovery-serverd-1.0.1" "fast-discovery-server" "fastdds" "ros-discovery")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
    endforeach()

    # adjust paths in batch files
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds" "$dir/../tools/fastdds/fastdds.py" "$dir/../fastdds/fastdds.py")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery" "$dir/../tools/fastdds/fastdds.py" "$dir/../fastdds/fastdds.py")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/fastdds/discovery/parser.py" "tool_path / '../../../bin'" "tool_path / '../../${PORT}'")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
