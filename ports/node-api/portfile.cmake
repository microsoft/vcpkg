vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF ecefbdd00f2cd04eaf1c06b6481abe9b031b5f0b
  SHA512 66e8464e74bcaa5e7d9987f5e1101b8df7b6cf4752d0df52a6f26b6897c6022fd39268dac7edc489887d2e9fd0fc6161077dcd55ba51995cbef59e9bbe94c54c
  HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
  set(base_path "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
  find_program(NODEJS NAMES node PATHS "${base_path}" "${base_path}/bin" NO_DEFAULT_PATHS REQUIRED)

  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/generateNodeLibDef.js" DESTINATION "${SOURCE_PATH}")

  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DNODEJS_EXECUTABLE="${NODEJS}"
  )

  vcpkg_cmake_install()
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME "node")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-node-api-config.cmake" @ONLY)
