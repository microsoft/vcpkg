
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2021.1
    SHA512 e8478eacb86415f75a1e5b3f66a0508b01a9f7e9d8b070eb0329ca56be137f5543dd42125a1033cb8552c01f46e11affd7fda866231b3742c66de9b4341930d5
    PATCHES
        cmake-install.patch
        install-config-typo.patch
        0001-don-t-use-MP4.patch
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${CURRENT_INSTALLED_DIR}
        -DSPIRV_WERROR=OFF
        -DSPIRV_SKIP_EXECUTABLES=${SKIP_EXECUTABLES} # option SPIRV_SKIP_TESTS follows this value
        -DENABLE_SPIRV_TOOLS_INSTALL=${TOOLS_INSTALL}
        -DSPIRV_TOOLS_BUILD_STATIC=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools TARGET_PATH share/SPIRV-Tools) # the directory name is capitalized as opposed to the package name
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-link TARGET_PATH share/SPIRV-Tools-link)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-opt TARGET_PATH share/SPIRV-Tools-opt)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-reduce TARGET_PATH share/SPIRV-Tools-reduce)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin") # only static linkage, i.e. no need to preserve .dll/.so files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/SPIRV-Tools-shared.dll")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/libSPIRV-Tools-shared.so")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/libSPIRV-Tools-shared.so")
if(TOOLS_INSTALL)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
