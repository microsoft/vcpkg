vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF f88e5824d2cfca5edc58c7c2101ec9a4ec36afac
  SHA512 92dc287e8930db6e00bde23b770f763dc3cf8a405a37b682bbd65e1dbde1f1f5161543fcc70b09eef07a5ce8bbe8f368ef84ac75003c122f42d1f6b9eaa8bd50
  HEAD_REF master
  PATCHES
    CMakeLists-targets.patch
    CMakeLists-windows.patch
)

if(VCPKG_TARGET_IS_IOS)
  # this case will report error since all executable will require BUNDLE DESTINATION
  set(BUILD_BINARIES OFF)
else()
  set(BUILD_BINARIES ON)  
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
    -DSKIP_GLSLANG_INSTALL=OFF
    -DENABLE_GLSLANG_BINARIES=${BUILD_BINARIES}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/glslang)

vcpkg_copy_pdbs()

if(NOT BUILD_BINARIES)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
else()
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
