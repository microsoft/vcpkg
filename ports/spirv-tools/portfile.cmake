vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2022.2
    SHA512 027819bb68a3cb42f086cab8089e0fe0b2ebcf40607811c6848d7d9f412ed3c977498d32dc7e37b828d0e6eb6924878e7c975c461fc5b171142a4ee1da2c1caa
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
 # the directory name is capitalized as opposed to the port name
if(WIN32)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools/cmake PACKAGE_NAME SPIRV-Tools)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-link/cmake PACKAGE_NAME SPIRV-Tools-link)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-lint/cmake PACKAGE_NAME SPIRV-Tools-lint)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-opt/cmake PACKAGE_NAME SPIRV-Tools-opt)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-reduce/cmake PACKAGE_NAME SPIRV-Tools-reduce)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools PACKAGE_NAME SPIRV-Tools DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-link PACKAGE_NAME SPIRV-Tools-link DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-lint PACKAGE_NAME SPIRV-Tools-lint DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-opt PACKAGE_NAME SPIRV-Tools-opt DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-reduce PACKAGE_NAME SPIRV-Tools-reduce) # now delete
endif()
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

if(WIN32)
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/debug/SPIRV-Tools" 
        "${CURRENT_PACKAGES_DIR}/debug/SPIRV-Tools-link"
        "${CURRENT_PACKAGES_DIR}/debug/SPIRV-Tools-lint"  
        "${CURRENT_PACKAGES_DIR}/debug/SPIRV-Tools-opt"
        "${CURRENT_PACKAGES_DIR}/debug/SPIRV-Tools-reduce" 
        "${CURRENT_PACKAGES_DIR}/SPIRV-Tools" 
        "${CURRENT_PACKAGES_DIR}/SPIRV-Tools-link" 
        "${CURRENT_PACKAGES_DIR}/SPIRV-Tools-lint" 
        "${CURRENT_PACKAGES_DIR}/SPIRV-Tools-opt" 
        "${CURRENT_PACKAGES_DIR}/SPIRV-Tools-reduce"
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
