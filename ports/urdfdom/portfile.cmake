include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  message(STATUS "urdfdom does not support static linkage. Building dynamically.")
  set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ros/urdfdom
  REF 1.0.0
  SHA512 50a218e596bcc0cecff904db2fa626bebc3902c4fe1f5ff8e08195e462b4d9a8c416a41f4773cabbcc71490060d3feff7e8528a76b824569dc7fdb0bda01ec3f
  HEAD_REF master
)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/0001_use_math_defines.patch
    ${CMAKE_CURRENT_LIST_DIR}/0002_fix_exports.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

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
