vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OpenMPT/openmpt
  REF 7da598b28acdb8ee8ea0ed93bcb57d680424f5cc # libopenmpt-0.5.12
  SHA512 0f5441518dbbbbae194c724c47238a3cad876d8eb81e6a89fed3801724a6ae023d6d8806f792dc2f44082f3849cd4e1130081db3668f9974170171227f70e879
  HEAD_REF master
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
