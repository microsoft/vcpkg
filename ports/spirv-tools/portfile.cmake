include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2018.1
    SHA512 0637c413dafd931e8222f9bf70a024f8b64116f0300c7732b86bcaff321188a0e746f79c1385ae23a7692e83194586b57692960d5be607fb2d7960731b6cd63f
    HEAD_REF master
    PATCHES
        CMake-targets.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}
        -DSPIRV_WERROR=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*${CMAKE_EXECUTABLE_SUFFIX}")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${EXES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-tools/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-tools/copyright)

vcpkg_test_cmake(PACKAGE_NAME spirv-tools)
