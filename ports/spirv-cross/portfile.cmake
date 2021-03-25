
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF 2021-01-15
    SHA512 f934ef61602223f6fe6d9c826ed5beb129beb7a30b18b389625d4fc0b1efa1b8df930a2a2d2a0b4f377ef2899e8e034239819a4c6629a78c666f72004464da93
    HEAD_REF master
)

if(VCPKG_TARGET_IS_IOS)
    message(STATUS "Using iOS trplet. Executables won't be created...")
    set(BUILD_CLI OFF)
else()
    set(BUILD_CLI ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
        -DSPIRV_CROSS_CLI=${BUILD_CLI}
        -DSPIRV_CROSS_SKIP_INSTALL=OFF
        -DSPIRV_CROSS_ENABLE_C_API=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

foreach(COMPONENT core c cpp glsl hlsl msl reflect util)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/spirv_cross_${COMPONENT}/cmake TARGET_PATH share/spirv_cross_${COMPONENT})
endforeach()

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# cleanup
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-cross/copyright COPYONLY)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
