vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ros/urdfdom
  REF 0da4b20675cdbe14b532d484a1c17df85b4e1584 # 1.0.4
  SHA512 cad59307fef466e2bbe3769a4123571d48223ea25a80dde76cb25c9f6dfc961570090d188ddaf8fc93f41f355ffa240eb00abe20cdea4a5ee3e49f56d1258686
  HEAD_REF master
  PATCHES
    0001_use_math_defines.patch
    0002_fix_exports.patch
    0003_import_prefix.patch
    0004_fix-dependency-console_bridge.patch
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

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    vcpkg_fixup_pkgconfig()
endif()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ ${CURRENT_PACKAGES_DIR}/tools/${PORT}/)

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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
