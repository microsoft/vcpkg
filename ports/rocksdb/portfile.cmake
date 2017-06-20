include(vcpkg_common_functions)

find_program(GIT git)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Rocksdb only supports x64")
endif()

set(VCPKG_PLATFORM_TOOLSET v140)
set(MSVS_VERSION 2015)


vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF v5.4.6
  SHA512 fe804335ef1b6e37df9b76ab665c1071253d62848878732e541e88444d9d226a1ac70a53a51641e1f554974711781d524d5069ac672589de7d2ec59874ec9290
  HEAD_REF master
)

LIST(APPEND ENV_REPLACE_LIST
  "set(GFLAGS_HOME \${CURRENT_INSTALLED_DIR})"
  "set(GFLAGS_INCLUDE \${GFLAGS_HOME}/include)"
  "set(GFLAGS_LIB_DEBUG \${GFLAGS_HOME}/debug/lib/gflags.lib)"
  "set(GFLAGS_LIB_RELEASE \${GFLAGS_HOME}/lib/gflags.lib)"
  "set(SNAPPY_HOME \${CURRENT_INSTALLED_DIR})"
  "set(SNAPPY_INCLUDE \${SNAPPY_HOME}/include)"
  "set(SNAPPY_LIB_DEBUG \${SNAPPY_HOME}/debug/lib/snappy.lib)"
  "set(SNAPPY_LIB_RELEASE \${SNAPPY_HOME}/lib/snappy.lib)"
  "set(LZ4_HOME \${CURRENT_INSTALLED_DIR})"
  "set(LZ4_INCLUDE \${LZ4_HOME}/include)"
  "set(LZ4_LIB_DEBUG \${LZ4_HOME}/debug/lib/lz4.lib)"
  "set(LZ4_LIB_RELEASE \${LZ4_HOME}/lib/lz4.lib)"
  "set(ZLIB_HOME \${CURRENT_INSTALLED_DIR})"
  "set(ZLIB_INCLUDE \${ZLIB_HOME}/include)"
  "set(ZLIB_LIB_DEBUG \${ZLIB_HOME}/debug/lib/zlib.lib)"
  "set(ZLIB_LIB_RELEASE \${ZLIB_HOME}/lib/zlib.lib)"
)
LIST(APPEND ENV_FIND_LIST
  "set(GFLAGS_HOME \$ENV{THIRDPARTY_HOME}/Gflags.Library)"
  "set(GFLAGS_INCLUDE \${GFLAGS_HOME}/inc/include)"
  "set(GFLAGS_LIB_DEBUG \${GFLAGS_HOME}/bin/debug/amd64/gflags.lib)"
  "set(GFLAGS_LIB_RELEASE \${GFLAGS_HOME}/bin/retail/amd64/gflags.lib)"
  "set(SNAPPY_HOME \$ENV{THIRDPARTY_HOME}/Snappy.Library)"
  "set(SNAPPY_INCLUDE \${SNAPPY_HOME}/inc/inc)"
  "set(SNAPPY_LIB_DEBUG \${SNAPPY_HOME}/bin/debug/amd64/snappy.lib)"
  "set(SNAPPY_LIB_RELEASE \${SNAPPY_HOME}/bin/retail/amd64/snappy.lib)"
  "set(LZ4_HOME \$ENV{THIRDPARTY_HOME}/LZ4.Library)"
  "set(LZ4_INCLUDE \${LZ4_HOME}/inc/include)"
  "set(LZ4_LIB_DEBUG \${LZ4_HOME}/bin/debug/amd64/lz4.lib)"
  "set(LZ4_LIB_RELEASE \${LZ4_HOME}/bin/retail/amd64/lz4.lib)"
  "set(ZLIB_HOME \$ENV{THIRDPARTY_HOME}/ZLIB.Library)"
  "set(ZLIB_INCLUDE \${ZLIB_HOME}/inc/include)"
  "set(ZLIB_LIB_DEBUG \${ZLIB_HOME}/bin/debug/amd64/zlib.lib)"
  "set(ZLIB_LIB_RELEASE \${ZLIB_HOME}/bin/retail/amd64/zlib.lib)"
)

message(STATUS "${SOURCE_PATH}/thirdparty.inc is here")

LIST( LENGTH ENV_REPLACE_LIST COUNT )
MATH(EXPR COUNT "${COUNT}-1")

file(READ "${SOURCE_PATH}/thirdparty.inc" THIRDY_PARTY)
foreach( INDEX RANGE ${COUNT})
  list (GET ENV_REPLACE_LIST ${INDEX} TO_REPLACE)
  list (GET ENV_FIND_LIST ${INDEX} TO_FIND)
  message(STATUS "Replacing ${TO_FIND} to  ${TO_REPLACE} ")
  string(REPLACE ${TO_FIND} ${TO_REPLACE} THIRDY_PARTY "${THIRDY_PARTY}")
endforeach()

file(WRITE "${SOURCE_PATH}/thirdparty.inc" "${THIRDY_PARTY}")


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  -DGIT_EXECUTABLE=${GIT}
  -DGFLAGS=1
  -DSNAPPY=1
  -DLZ4=1
  -DZLIB=1
  -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
)


vcpkg_build_cmake()
