include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ros/urdfdom
  REF 1.0.3
  SHA512 240181d9c61dd7544f16a79a400d9a2c4dc0a682bef165b46529efcb4b31e2a34e27896933b60b9ddbaa5c4a8d575ebda42752599ff3b0a98d1eeef8f9b0b7a7
  HEAD_REF master
  PATCHES
    0001_use_math_defines.patch
    0002_fix_exports.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/urdfdom/cmake)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/urdfdom)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/urdfdom)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ ${CURRENT_PACKAGES_DIR}/tools/urdfdom/)

file(GLOB URDFDOM_DLLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
foreach(URDFDOM_DLL_DEBUG ${URDFDOM_DLLS_DEBUG})
  file(COPY ${URDFDOM_DLL_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(REMOVE ${URDFDOM_DLL_DEBUG})
endforeach()

file(GLOB URDFDOM_DLLS_RELEASE ${CURRENT_PACKAGES_DIR}/lib/*.dll)
foreach(URDFDOM_DLL_RELEASE ${URDFDOM_DLLS_RELEASE})
  file(COPY ${URDFDOM_DLL_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE ${URDFDOM_DLL_RELEASE})
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/urdfdom RENAME copyright)
