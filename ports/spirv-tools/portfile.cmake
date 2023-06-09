vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2022.4
    SHA512 d93e97e168c50f545cc42418603ffc5fa6299bb3cc30d927444e4de0d955abc5dd481c9662a59cd49fc379da6bcc6df6fb747947e3dc144cee9b489aff7c4785
    PATCHES
        cmake-config-dir.diff
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_IOS)
    message(STATUS "Using iOS trplet. Executables won't be created...")
    set(TOOLS_INSTALL OFF)
    set(SKIP_EXECUTABLES ON) 
else()
    set(TOOLS_INSTALL ON)
    set(SKIP_EXECUTABLES OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${CURRENT_INSTALLED_DIR}
        -DSPIRV_WERROR=OFF
        -DSPIRV_SKIP_TESTS=ON
        -DSPIRV_SKIP_EXECUTABLES=${SKIP_EXECUTABLES}
        -DENABLE_SPIRV_TOOLS_INSTALL=${TOOLS_INSTALL}
        -DSPIRV_TOOLS_BUILD_STATIC=ON
        -DENABLE_SPIRV_TOOLS_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools PACKAGE_NAME spirv-tools DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-link PACKAGE_NAME spirv-tools-link DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-lint PACKAGE_NAME spirv-tools-lint DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-opt PACKAGE_NAME spirv-tools-opt DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-reduce PACKAGE_NAME spirv-tools-reduce) # now delete
vcpkg_fixup_pkgconfig()

if(TOOLS_INSTALL)
    vcpkg_copy_tools(
        TOOL_NAMES 
            spirv-as 
            spirv-cfg 
            spirv-dis 
            spirv-link 
            spirv-lint 
            spirv-opt 
            spirv-reduce 
            spirv-val 
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # lesspipe.sh is the only file there
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
