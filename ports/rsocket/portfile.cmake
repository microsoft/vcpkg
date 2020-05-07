if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  # Because folly only supports the x64 architecture.
  message(FATAL_ERROR "Rsocket only supports the x64 architecture.")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO rsocket/rsocket-cpp #v2020.05.04.00
  REF 8038d05e741c3d3ecd6adb069b4a1b3daa230e14
  SHA512 d7bc93af7b6130d73fa0823f534ad57a531dfa7d7aa990a2a1a1b72b6761db7eeb60573d0d38f55daa991554e3ab4ac507047f8051a4390b3343cd708a48efbb
  HEAD_REF master
  PATCHES
    fix-cmake-config.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_BENCHMARKS=OFF
)

vcpkg_install_cmake()

# rsocket-cpp will install two package rsocket and yarpl.
# if we use `vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)`,
# the result may be not what we want.
# - x64-linux
#    └── share
#         └── rsocket
#               ├─ rsocket
#               │   └── rsocket-config.cmake
#               └── yarpl
#                   └── yarpl-config.cmake
# so we need `TARGET_PATH share` to avoid redundant subdirectory.
# - x64-linux
#    └── share
#         ├── rsocket
#         │   └── rsocket-config.cmake
#         └── yarpl
#             └── yarpl-config.cmake
# we can't call `vcpkg_fixup_cmake_targets` twice at least for now.
# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rsocket)
# vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/yarpl)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# There should be no empty directories in /home/vcpkg/vcpkg/packages/rsocket-cpp_x64-linux
file(REMOVE_RECURSE
  ${CURRENT_PACKAGES_DIR}/include/yarpl/perf
  ${CURRENT_PACKAGES_DIR}/include/yarpl/cmake
  ${CURRENT_PACKAGES_DIR}/include/yarpl/test
  ${CURRENT_PACKAGES_DIR}/include/rsocket/examples
  ${CURRENT_PACKAGES_DIR}/include/rsocket/test
)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
