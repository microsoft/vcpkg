vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OpenMPT/openmpt
  REF libopenmpt-0.6.7
  SHA512 0c12968cc9c7b4913e03dba3493c67deebf1dc96923d5dd40f1bc4222e98c4618b70fbe0903da8a9039bf58cac4a9377091138eb5ae315ffe4f52831dff52c0e
)

file(READ ${CMAKE_CURRENT_LIST_DIR}/vcpkg.json vcpkg_json)
string(JSON version GET "${vcpkg_json}" "version")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DVERSION=${version}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libopenmpt/libopenmpt_config.h "defined(LIBOPENMPT_USE_DLL)" "0")
else()
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libopenmpt/libopenmpt_config.h "defined(LIBOPENMPT_USE_DLL)" "1")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
