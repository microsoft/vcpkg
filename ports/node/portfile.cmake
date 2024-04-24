vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node
  REF "v${VERSION}"
  SHA512 f601686b17bac452c7d64551bdea51929bfe82ca5477da60ae3f52367c6e0b3f8172c8a407a80f2d4f98c6462a41a012a59aaa335b0e3f19cfff52b78d7ad93b
  HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
  set(nodejs_options openssl-no-asm static x64)

  if(NOT DEFINED VCPKG_BUILD_TYPE)
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
    file(COPY "${path}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  endforeach()
else()
  set(nodejs_options)

  execute_process(
    COMMAND "${SOURCE_PATH}/configure" "--ninja" ${nodejs_options}
    WORKING_DIRECTORY "${SOURCE_PATH}"

    OUTPUT_VARIABLE NODE_BUILD_SH_OUT
    ERROR_VARIABLE NODE_BUILD_SH_ERR
    RESULT_VARIABLE NODE_BUILD_SH_RES
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )

  if(NOT NODE_BUILD_SH_RES EQUAL 0)
    message(FATAL_ERROR "Failed to configure nodejs (code ${NODE_BUILD_SH_RES})")
  endif()

  vcpkg_install_make()
endif()

# main header
file(COPY "${SOURCE_PATH}/src/node.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# node.h requirements
file(COPY "${SOURCE_PATH}/src/node_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/node_version.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# TODO: v8.h
# TODO: v8-platform.h

# node_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/src/node_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# js_native_api.h requirements
file(COPY "${SOURCE_PATH}/src/js_native_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
