vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simbody/simbody
    REF a8f49c84e98ccf3b7e6f05db55a29520e5f9c176
    SHA512 85493e00286163ed8ac6aa71edf8d34701d62ac5e5f472f654faa8852eb7fd569ffc0d76fd2e88bebcd3f79df9e35fc702a029890defb8b0d84d0d0512268960
    HEAD_REF master
    PATCHES
        "0001-Use-vcpkg-deps.patch"
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Platform/Windows")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

if(WIN32)
    set(SIMBODY_CMAKE_DIR cmake)
elseif(UNIX)
    set(SIMBODY_CMAKE_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/simbody/)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH ${SIMBODY_CMAKE_DIR})

vcpkg_copy_tools(
    TOOL_NAMES simbody-visualizer
    AUTO_CLEAN
)
vcpkg_copy_tools(
    TOOL_NAMES simbody-visualizer_d
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/debug/bin
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}
    AUTO_CLEAN
)
# Copy debug dependencies not moved by vcpkg_copy_tool_dependencies for simbody-visualizer_d
file(COPY "${CURRENT_PACKAGES_DIR}/debug/bin/SimTKcommon_d.dll"
          "${CURRENT_PACKAGES_DIR}/debug/bin/SimTKmath_d.dll"
          "${CURRENT_PACKAGES_DIR}/debug/bin/SimTKsimbody_d.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc/api" "${CURRENT_PACKAGES_DIR}/doc/api")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
