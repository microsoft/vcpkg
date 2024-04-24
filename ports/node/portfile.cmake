vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node
  REF "v${VERSION}"
  SHA512 0
  HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
  set(nodejs_options openssl-no-asm static x64)

  if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
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
    file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endforeach()

  file(GLOB libs "${SOURCE_PATH}/Release/*.lib")
  foreach(path ${libs})
    if(NOT "${path}" MATCHES ".*cctest\.lib|.*embedtest\.lib")
      file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()
  endforeach()
else()
  find_program(MAKE make REQUIRED)

  if(NOT "${VCPKG_BUILD_TYPE}" STREQUAL "release")
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
    vcpkg_execute_build_process(
      COMMAND "${MAKE}" "-j${VCPKG_CONCURRENCY}" ${MAKE_OPTIONS}
      NO_PARALLEL_COMMAND "${MAKE}" "-j1" ${MAKE_OPTIONS}
      WORKING_DIRECTORY "${SOURCE_PATH}"
      LOGNAME "build-${TARGET_TRIPLET}-dbg"
    )
    file(GLOB libs "${SOURCE_PATH}/Debug/*.a")
    foreach(path ${libs})
      file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endforeach()
  endif()

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
  vcpkg_execute_build_process(
    COMMAND "${MAKE}" "-j${VCPKG_CONCURRENCY}" ${MAKE_OPTIONS}
    NO_PARALLEL_COMMAND "${MAKE}" "-j1" ${MAKE_OPTIONS}
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "build-${TARGET_TRIPLET}-rel"
  )
  file(GLOB libs "${SOURCE_PATH}/Release/*.a")
  foreach(path ${libs})
    file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  endforeach()

endif()

# main header
file(COPY "${SOURCE_PATH}/src/node.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# node.h requirements
file(COPY "${SOURCE_PATH}/src/node_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/node_version.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

#file(COPY "${SOURCE_PATH}/src/deps/v8/include/v8.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
#file(COPY "${SOURCE_PATH}/src/deps/v8/include/v8-platform.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/cppgc/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/cppgc")
endforeach()

file(GLOB v8_headers "${SOURCE_PATH}/src/deps/v8/include/libplatform/*.h")
foreach(v8_header ${v8_headers})
  file(COPY "${v8_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/libplatform")
endforeach()

# node_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/node_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# js_native_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
