
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF v2.14.0
    SHA512 cf3628ac7598c83f09e3975de9fb59e868797adc331d7b4a226c38c0bbd1f7ce15deeb7cedee938a86a68426585e0b5646a84f40705c9a04553b7e37f20b2a4d
    HEAD_REF master
    PATCHES
        fix-find-package-asio.patch
        disable-symlink.patch
)

set(extra_opts "")
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    # when cross-compiling, try_run will not work.
    set(extra_opts
        -DSM_RUN_RESULT=TRUE
        -DSM_RUN_RESULT__TRYRUN_OUTPUT=
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${extra_opts}
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
