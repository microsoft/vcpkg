set(base_path "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
find_program(NODEJS NAMES node PATHS "${base_path}" "${base_path}/bin" NO_DEFAULT_PATHS)

if(NOT NODEJS)
  message(FATAL_ERROR "node not found in '${CURRENT_HOST_INSTALLED_DIR}/tools/node'")
endif()

if(VCPKG_HOST_IS_WINDOWS)
  set(NODEJS_BIN_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
  set(NODEJS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
else()
  set(NODEJS_BIN_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin")
  set(NODEJS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
endif()

vcpkg_add_to_path(PREPEND "${NODEJS_BIN_DIR}")

if(VCPKG_HOST_IS_WINDOWS)
  set(npm_command "${NODEJS_BIN_DIR}/npm.cmd")
else()
  set(npm_command "${NODEJS_BIN_DIR}/npm")
endif()

file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-output")
file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-home")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-output")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-home")

set(npm_args --prefix "${NODEJS_BIN_DIR}" install cmake-js@7.0.0-3)
execute_process(COMMAND "${npm_command}" ${npm_args}
  WORKING_DIRECTORY ${NODEJS_BIN_DIR}
  RESULT_VARIABLE npm_result
  OUTPUT_VARIABLE npm_output
)

if(NOT "${npm_result}" STREQUAL "0")
  message(FATAL_ERROR "${npm_command} ${npm_args} exited with ${npm_result}:\n${npm_output}")
endif()

# Prevent pollution of user home directory
file(READ "${NODEJS_BIN_DIR}/node_modules/cmake-js/lib/environment.js" environment_js)
string(REPLACE "process.env[(os.platform() === \"win32\") ? \"USERPROFILE\" : \"HOME\"]" "\"${DOWNLOADS}/tmp-cmakejs-home\"" environment_js "${environment_js}")
file(WRITE "${NODEJS_BIN_DIR}/node_modules/cmake-js/lib/environment.js" "${environment_js}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(cmake_js_arch "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(cmake_js_arch "ia32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(cmake_js_arch "arm64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(cmake_js_arch "arm")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/package.json" DESTINATION "${NODEJS_BIN_DIR}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/cmake-js-fetch" DESTINATION "${NODEJS_BIN_DIR}")

set(npm_args
  # npm arguments:
  --prefix "${NODEJS_BIN_DIR}"
  run cmake-js-fetch
  --scripts-prepend-node-path

  # cmake-js arguments:
  -- --out "${DOWNLOADS}/tmp-cmakejs-output" --arch "${cmake_js_arch}"
)
execute_process(COMMAND "${npm_command}" ${npm_args}
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  RESULT_VARIABLE npm_result
  OUTPUT_VARIABLE npm_output
)

if(NOT "${npm_result}" STREQUAL "0")
  message(FATAL_ERROR "${npm_command} ${npm_args} exited with ${npm_result}:\n${npm_output}")
endif()

include("${DOWNLOADS}/tmp-cmakejs-output/node.cmake")

file(COPY "${CMAKE_JS_INC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Emptyness of the variables depends on the platform
if(CMAKE_JS_LIB)
  file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

if(CMAKE_JS_SRC)
  file(COPY "${CMAKE_JS_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

# Handle copyright
file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

# Vcpkg remove doesn't remove cmake-js, so we need to remove it manually right now
file(GLOB cmakejs_files "${NODEJS_BIN_DIR}/cmake-js*")
file(REMOVE ${cmakejs_files})
file(REMOVE_RECURSE "${NODEJS_BIN_DIR}/node_modules/cmake-js")
file(REMOVE_RECURSE "${NODEJS_BIN_DIR}/cmake-js-fetch")
file(REMOVE "${NODEJS_BIN_DIR}/package.json")