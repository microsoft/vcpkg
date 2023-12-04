vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/gfxreconstruct
    REF "vulkan-sdk-${VERSION}"
    SHA512 d6a5571c24c85e8a33d12328c6fa263a800f9b06b35ef8e051bdf52dd6e6d6c8c0337d7bca8c0a1e2e805e593759bddd2e6b03af75ee4cb29ea65dd14aa3b971
    HEAD_REF main
)

#BUILD_STATIC 

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS 
    -DBUILD_WERROR=OFF
    "-DVULKAN_HEADER=${CURRENT_INSTALLED_DIR}/include/vulkan/vulkan_core.h"
    -DD3D12_SUPPORT=OFF
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(tools compress convert extract info optimize replay)
list(TRANSFORM tools PREPEND "gfxrecon-")

vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
file(GLOB files "${CURRENT_PACKAGES_DIR}/bin/*.py" "${CURRENT_PACKAGES_DIR}/bin/*.json")
foreach(file IN LISTS files)
  string(REPLACE "/bin/" "/tools/${PORT}/" new_file "${file}")
  file(RENAME "${file}" "${new_file}")
endforeach()

set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
