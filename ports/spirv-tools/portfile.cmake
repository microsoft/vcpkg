
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2022.1
    SHA512 19ff4386c74c15f9b870d5348b76c7d643da5bf1637b1faed153d9ec9f00de941a83a22782f169b4aa5001c715721937c3bb3bc07541a60e503a0455a1d2287e
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
        -DSPIRV_SKIP_EXECUTABLES=${SKIP_EXECUTABLES} # option SPIRV_SKIP_TESTS follows this value
        -DENABLE_SPIRV_TOOLS_INSTALL=${TOOLS_INSTALL}
        -DSPIRV_TOOLS_BUILD_STATIC=ON
        -DENABLE_SPIRV_TOOLS_INSTALL=ON
)

vcpkg_cmake_install()
 # the directory name is capitalized as opposed to the package name
if(WIN32)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools/cmake PACKAGE_NAME SPIRV-Tools)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-link/cmake PACKAGE_NAME SPIRV-Tools-link)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-lint/cmake PACKAGE_NAME SPIRV-Tools-lint)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-opt/cmake PACKAGE_NAME Tools-opt)
    vcpkg_cmake_config_fixup(CONFIG_PATH SPIRV-Tools-reduce/cmake PACKAGE_NAME SPIRV-Tools-reduce)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools PACKAGE_NAME SPIRV-Tools)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-link PACKAGE_NAME SPIRV-Tools-link)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-lint PACKAGE_NAME SPIRV-Tools-lint)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-opt PACKAGE_NAME Tools-opt)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-reduce PACKAGE_NAME SPIRV-Tools-reduce)
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin") # only static linkage, i.e. no need to preserve .dll/.so files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/SPIRV-Tools-shared.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libSPIRV-Tools-shared.so")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libSPIRV-Tools-shared.so")
if(TOOLS_INSTALL)
    vcpkg_copy_tools(TOOL_NAMES spirv-as spirv-cfg spirv-dis spirv-link spirv-lint spirv-opt spirv-reduce spirv-val AUTO_CLEAN)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
