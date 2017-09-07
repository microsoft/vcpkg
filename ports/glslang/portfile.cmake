include(vcpkg_common_functions)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message(WARNING "Dynamic not supported. Building static")
  set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF 3a21c880500eac21cdf79bef5b80f970a55ac6af
  SHA512 a6b2f589d432015d3830027dee377350529bec9c339a8de24aa52bab5ca52b3e17e2163d3bd1a7d91f7a08c446ebfe86d64bbbbae5a23af831d2e0cb724f7418
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
