set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-ValidationLayers
    REF "vulkan-sdk-${VERSION}"
    SHA512 5088bfb212595d5c1bd052f3e2e7d52ffa1c329625576116876a248daba51c9ba86297ebf8ffb6bd1e8f78bf161409a603aa4d145032664623292d53ed541514
    HEAD_REF main
    PATCHES
        disable_vendored_phmap.diff
)

file(REMOVE_RECURSE "${SOURCE_PATH}/layers/external/parallel_hashmap") # ensure that we use vcpkg's parallel-hashmap instead of upstream's vendored copy

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(layer_path "<vcpkg_installed>/bin")
if(NOT VCPKG_TARGET_IS_WINDOWS)
 set(layer_path "<vcpkg_installed>/share/vulkan/explicit_layer.d")
endif()
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
