include(vcpkg_common_functions)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "Dynamic not supported. Building static")
  set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF  1c573fbcfba6b3d631008b1babc838501ca925d3
  SHA512 4f04dc39d9a70959ded1f4fe05ca5c7b0413c05bc3f049c11b5be7c8e1a70675f4221c9d8c712e7695f30eadb9bd7d0f1e71f431a6c9d4fea2cd2abbc73bd49a
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY "${SOURCE_PATH}/glslang/Public" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang)
file(COPY "${SOURCE_PATH}/glslang/Include" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang)
file(COPY "${SOURCE_PATH}/glslang/MachineIndependent/Versions.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang/MachineIndependent)
file(COPY "${SOURCE_PATH}/SPIRV/Logger.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${SOURCE_PATH}/SPIRV/spirv.hpp" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${SOURCE_PATH}/SPIRV/GlslangToSpv.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${CURRENT_PACKAGES_DIR}/bin/glslangValidator.exe" DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/glslangValidator.exe")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/glslangValidator.exe")
file(COPY "${CURRENT_PACKAGES_DIR}/bin/spirv-remap.exe" DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/spirv-remap.exe")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/spirv-remap.exe")

file(GLOB BIN_DIR "${CURRENT_PACKAGES_DIR}/bin/*")
list(LENGTH BIN_DIR BIN_DIR_SIZE)
if(${BIN_DIR_SIZE} EQUAL 0)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()
file(GLOB DEBUG_BIN_DIR "${CURRENT_PACKAGES_DIR}/debug/bin/*")
list(LENGTH DEBUG_BIN_DIR DEBUG_BIN_DIR_SIZE)
if(${DEBUG_BIN_DIR_SIZE} EQUAL 0)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
