vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2021.1
    SHA512 e8478eacb86415f75a1e5b3f66a0508b01a9f7e9d8b070eb0329ca56be137f5543dd42125a1033cb8552c01f46e11affd7fda866231b3742c66de9b4341930d5
    PATCHES
        cmake-install.patch
        install-config-typo.patch
        0001-don-t-use-MP4.patch
        fix-build-type.patch
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
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${CURRENT_INSTALLED_DIR}
        -DSPIRV_WERROR=OFF
        -DSPIRV_SKIP_EXECUTABLES=${SKIP_EXECUTABLES} # option SPIRV_SKIP_TESTS follows this value
        -DENABLE_SPIRV_TOOLS_INSTALL=${TOOLS_INSTALL}
        -DSPIRV_TOOLS_BUILD_STATIC=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME SPIRV-Tools)
vcpkg_cmake_config_fixup(PACKAGE_NAME SPIRV-Tools-link)
vcpkg_cmake_config_fixup(PACKAGE_NAME SPIRV-Tools-opt)
vcpkg_cmake_config_fixup(PACKAGE_NAME SPIRV-Tools-reduce)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(TOOLS_INSTALL)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/spirv-lesspipe.sh" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    
    vcpkg_copy_tools(TOOL_NAMES spirv-as spirv-cfg spirv-dis spirv-link spirv-opt spirv-reduce spirv-val AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
