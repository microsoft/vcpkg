vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF 4fdbdd171011cba57ab2888ef0995451e8aded95
  SHA512 84289b291d542865c2fb649dc3a43dd6840ac879a913fbcce0a0c848d4a3fb76e7bf02ad46f36e62cde47dc9e0dac9baad2f78615c91cd40fccb702234c965a3
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
