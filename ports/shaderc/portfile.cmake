#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/shaderc
    REF "v${VERSION}"
    SHA512 b8758884d5cd67f5536f30838295e618544df38e3ca3e2b1379757bc57464d333c3263c5fd19e5b4a735284fde7c3d4de9075a414691b2e86ba069bcff2cd616
    HEAD_REF master
    PATCHES 
        disable-update-version.patch
        fix-build-type.patch
        cmake-config-export.patch
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/build-version.inc ${SOURCE_PATH}/glslc/src/build-version.inc)

set(OPTIONS "")
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DSHADERC_ENABLE_SHARED_CRT=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

# Add these libraries to the pkgconfig file since we patch the build to link against these
set(EXTRA_STATIC_PKGCONFIG_LIBS "-lglslang -lSPIRV-Tools-opt -lSPIRV-Tools")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DSHADERC_ENABLE_EXAMPLES=OFF
        -DSHADERC_SKIP_TESTS=true 
        "-DEXTRA_STATIC_PKGCONFIG_LIBS=${EXTRA_STATIC_PKGCONFIG_LIBS}"
)

vcpkg_cmake_install()
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/shaderc.pc" "-lglslang" "-lglslangd")
    endif()
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/shaderc.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-shaderc CONFIG_PATH share/unofficial-shaderc)

vcpkg_copy_tools(TOOL_NAMES glslc AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
