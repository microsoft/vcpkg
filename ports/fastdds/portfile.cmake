
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF "v${VERSION}"
    SHA512 8ccf3c976220719db59515ec680bb68dbd3bd726f6b6f29b3e9d19acd9b40545e8315109d5ab0c60bc55af7288b890e22f40a513ab56443c4b1c1a40c4d02bb0
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

vcpkg_cmake_config_fixup(CONFIG_PATH share/fastdds/cmake)

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
