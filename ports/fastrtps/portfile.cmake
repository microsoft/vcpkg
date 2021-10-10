vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-DDS
    REF v2.4.0
    SHA512 2E9C0378AF86DD657391D577F6951096DD45970A2C4D9C384EE5A452A1DD129E6E0AED91E0B908A35A04CAF979253700560561D34082DA81FE737FE104C149AF
    HEAD_REF master
    PATCHES
        fix-find-package-asio.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/fastrtps/cmake")

if(VCPKG_TARGET_IS_WINDOWS)
    # copy tools from "bin" to "tools" folder
    # on Windows, either "fast-discovery-server.exe" (symlink) or "fast-discovery-server.bat" may be present, depending on if the installation ran with administrator privileges
    foreach(TOOL "fast-discovery-server-1.0.0.exe" "fast-discovery-server.exe" "fast-discovery-server.bat" "fastdds.bat" "ros-discovery.bat")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
            file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
        endif()
    endforeach()

    # remove tools from debug builds
    foreach(TOOL "fast-discovery-serverd-1.0.0.exe" "fast-discovery-serverd.exe" "fast-discovery-server.bat" "fastdds.bat" "ros-discovery.bat")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
        endif()
    endforeach()

    # adjust paths in batch files
    file(READ "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds.bat" CONTENTS)
    string(REPLACE "%dir%\\..\\tools\\fastdds\\fastdds.py" "%dir%\\..\\fastdds\\fastdds.py" CONTENTS "${CONTENTS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds.bat" "${CONTENTS}")
    file(READ "${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery.bat" CONTENTS)
    string(REPLACE "%dir%\\..\\tools\\fastdds\\fastdds.py" "%dir%\\..\\fastdds\\fastdds.py" CONTENTS "${CONTENTS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery.bat" "${CONTENTS}")

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
elseif(VCPKG_TARGET_IS_LINUX)
    # copy tools from "bin" to "tools" folder
    foreach(TOOL "fast-discovery-server-1.0.0" "fast-discovery-server" "fastdds" "ros-discovery")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
    endforeach()

    # remove tools from debug builds
    foreach(TOOL "fast-discovery-serverd-1.0.0" "fast-discovery-server" "fastdds" "ros-discovery")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
    endforeach()

    # adjust paths in batch files
    file(READ "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds" CONTENTS)
    string(REPLACE "$dir/../tools/fastdds/fastdds.py" "$dir/../fastdds/fastdds.py" CONTENTS "${CONTENTS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fastdds" "${CONTENTS}")
    file(READ "${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery" CONTENTS)
    string(REPLACE "$dir/../tools/fastdds/fastdds.py" "$dir/../fastdds/fastdds.py" CONTENTS "${CONTENTS}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/ros-discovery" "${CONTENTS}")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
