include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Cross
    REF 2019-07-26
    SHA512 25bc0e5e7f313d01f70a4f106b9b42bc1975473e3f2fdcd7a48bf83b7865386366ebd5994efd2ae5f8d95c9abcbdefb46725b52ddb8dfb15169d621ff258a8ba
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

foreach(COMPONENT core cpp glsl hlsl msl reflect util)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/spirv_cross_${COMPONENT}/cmake TARGET_PATH share/spirv_cross_${COMPONENT})
endforeach()

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# cleanup
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-cross/copyright COPYONLY)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
