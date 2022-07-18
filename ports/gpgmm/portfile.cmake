vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gpgmm
    REF v0.0.4
    SHA512 2ffc3c8299f2d10cb1c0013cd306ba45781a644fa0aa426ef1dfa616e4b53671461a376f65b7068b1ff8a4a2d1a6f9539664174eb5830ea6a760ef5e5d0fc6b0
    HEAD_REF main
    PATCHES
        fix-dependency-vulkan.patch
        fix-binary-path-and-install-hdrs.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DGPGMM_ENABLE_VK=ON
        "-DGPGMM_VK_TOOLS_DIR=$ENV{VULKAN_SDK}/Tools"
        -DGPGMM_STANDALONE=OFF
        -DGPGMM_ENABLE_TESTS=OFF
    OPTIONS_DEBUG
        -DGPGMM_ALWAYS_ASSERT=ON
        -DGPGMM_FORCE_TRACING=ON
        -DGPGMM_ENABLE_DEVICE_LEAK_CHECKS=ON
        -DGPGMM_ENABLE_ALLOCATOR_LEAK_CHECKS=ON
        -DGPGMM_ENABLE_MEMORY_LEAK_CHECKS=ON
        -DGPGMM_ENABLE_RESOURCE_MEMORY_ALIGN_CHECKS=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
