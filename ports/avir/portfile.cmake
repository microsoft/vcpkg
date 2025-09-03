set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avaneev/avir
  REF "${VERSION}"
  SHA512 f3ca9b55c9169b6f9179d14c59738ce06842d205f19f39638fc853cd7c565b4b96ff7927c168c0501cc5664a7885226d888293280f523b28ea99c80b0bb81577
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL 
  "${SOURCE_PATH}/avir.h" 
  "${SOURCE_PATH}/avir_dil.h" 
  "${SOURCE_PATH}/avir_float4_sse.h" 
  "${SOURCE_PATH}/avir_float8_avx.h"
  "${SOURCE_PATH}/lancir.h"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include/avir")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
