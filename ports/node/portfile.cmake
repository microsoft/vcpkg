vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node
  REF "v${VERSION}"
  SHA512 f601686b17bac452c7d64551bdea51929bfe82ca5477da60ae3f52367c6e0b3f8172c8a407a80f2d4f98c6462a41a012a59aaa335b0e3f19cfff52b78d7ad93b
  HEAD_REF main
)


set(nodejs_options openssl-no-asm static x64)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
  execute_process(
    COMMAND "${SOURCE_PATH}/vcbuild.bat" ${nodejs_options}
    WORKING_DIRECTORY "${SOURCE_PATH}"

    OUTPUT_VARIABLE NODE_BUILD_SH_OUT
    ERROR_VARIABLE NODE_BUILD_SH_ERR
    RESULT_VARIABLE NODE_BUILD_SH_RES
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
  )
  if (NOT NODE_BUILD_SH_RES EQUAL 0)
    message(FATAL_ERROR "Failed to build nodejs (code ${NODE_BUILD_SH_RES})")
  endif()
endif()
