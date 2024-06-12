vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node
  REF "v${VERSION}"
  SHA512 cb88b3576ac810ceace7d5824d5a6e1c4181a9327f1420d6eb1546a03a22f5f80bdddcbef6bc478ce4cb62dcd724b7a04eda707845a4003b96a5d6aed5463b37
  HEAD_REF main
)

# Fixes arm64-windows host building x64-windows target
vcpkg_replace_string("${SOURCE_PATH}/configure.py" "'ARM64'  : 'arm64'" "'ARM64'  : 'x64'")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
  set(nodejs_options openssl-no-asm static ${VCPKG_TARGET_ARCHITECTURE})

  if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
    message(STATUS "Building nodejs Debug")

    execute_process(
      COMMAND "${SOURCE_PATH}/vcbuild.bat" debug ${nodejs_options}
      WORKING_DIRECTORY "${SOURCE_PATH}"

      OUTPUT_VARIABLE NODE_BUILD_SH_OUT
      ERROR_VARIABLE NODE_BUILD_SH_ERR
      RESULT_VARIABLE NODE_BUILD_SH_RES
      ECHO_OUTPUT_VARIABLE
      ECHO_ERROR_VARIABLE
    )
    if(NOT NODE_BUILD_SH_RES EQUAL 0)
      message(FATAL_ERROR "Failed to build nodejs Debug (code ${NODE_BUILD_SH_RES})")
    endif()
  endif()

  message(STATUS "Building nodejs Release")

  execute_process(
    COMMAND "${SOURCE_PATH}/vcbuild.bat" release ${nodejs_options}
    WORKING_DIRECTORY "${SOURCE_PATH}"

    OUTPUT_VARIABLE NODE_BUILD_SH_OUT
    ERROR_VARIABLE NODE_BUILD_SH_ERR
    RESULT_VARIABLE NODE_BUILD_SH_RES
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )

  if(NOT NODE_BUILD_SH_RES EQUAL 0)
    message(FATAL_ERROR "Failed to build nodejs Release (code ${NODE_BUILD_SH_RES})")
  endif()

  file(GLOB libs_debug "${SOURCE_PATH}/Debug/*.lib")
  foreach(path ${libs_debug})
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/node-embedder-api")
    file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/node-embedder-api")
  endforeach()

  file(GLOB libs "${SOURCE_PATH}/Release/*.lib")
  foreach(path ${libs})
    if(NOT "${path}" MATCHES ".*cctest\.lib|.*embedtest\.lib")
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/node-embedder-api")
      file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/node-embedder-api")
    endif()
  endforeach()
else()
  find_program(MAKE make REQUIRED)

  if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
    message(STATUS "Configuring nodejs Debug")

    execute_process(
      COMMAND "${SOURCE_PATH}/configure" "--debug"
      WORKING_DIRECTORY "${SOURCE_PATH}"

      OUTPUT_VARIABLE NODE_BUILD_SH_OUT
      ERROR_VARIABLE NODE_BUILD_SH_ERR
      RESULT_VARIABLE NODE_BUILD_SH_RES
      ECHO_OUTPUT_VARIABLE
      ECHO_ERROR_VARIABLE
    )

    if(NOT NODE_BUILD_SH_RES EQUAL 0)
      message(FATAL_ERROR "Failed to configure nodejs debug (code ${NODE_BUILD_SH_RES})")
    endif()

    message(STATUS "Building nodejs Debug")
    
    vcpkg_execute_build_process(
      COMMAND "${MAKE}" "-j${VCPKG_CONCURRENCY}" ${MAKE_OPTIONS}
      NO_PARALLEL_COMMAND "${MAKE}" "-j1" ${MAKE_OPTIONS}
      WORKING_DIRECTORY "${SOURCE_PATH}"
      LOGNAME "build-${TARGET_TRIPLET}-dbg"
    )

    file(GLOB libs "${SOURCE_PATH}/Debug/*.a")
    foreach(path ${libs})
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/node-embedder-api")
      file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/node-embedder-api")
    endforeach()
  endif()

  message(STATUS "Configuring nodejs Release")

  execute_process(
    COMMAND "${SOURCE_PATH}/configure"
    WORKING_DIRECTORY "${SOURCE_PATH}"

    OUTPUT_VARIABLE NODE_BUILD_SH_OUT
    ERROR_VARIABLE NODE_BUILD_SH_ERR
    RESULT_VARIABLE NODE_BUILD_SH_RES
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )

  if(NOT NODE_BUILD_SH_RES EQUAL 0)
    message(FATAL_ERROR "Failed to configure nodejs release (code ${NODE_BUILD_SH_RES})")
  endif()

  message(STATUS "Building nodejs Release")
  
  vcpkg_execute_build_process(
    COMMAND "${MAKE}" "-j${VCPKG_CONCURRENCY}" ${MAKE_OPTIONS}
    NO_PARALLEL_COMMAND "${MAKE}" "-j1" ${MAKE_OPTIONS}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "build-${TARGET_TRIPLET}-rel"
  )
  
  file(GLOB libs "${SOURCE_PATH}/Release/*.a")
  foreach(path ${libs})
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/node-embedder-api")
    file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/node-embedder-api")
  endforeach()

endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")

# main header
file(COPY "${SOURCE_PATH}/src/node.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")

# node.h requirements
file(COPY "${SOURCE_PATH}/src/node_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")
file(COPY "${SOURCE_PATH}/src/node_version.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")
endforeach()

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/cppgc/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api/cppgc")
endforeach()

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/libplatform/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api/libplatform")
endforeach()

# node_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")
file(COPY "${SOURCE_PATH}/src/node_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")

# js_native_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node-embedder-api")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
