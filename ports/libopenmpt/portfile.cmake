vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OpenMPT/openmpt
  REF 6860d1dec9bd31ed450a44148e789c4054925ed0 # libopenmpt-0.6.7
  SHA512 04c9d6e2d604dc412574f20ec2ef055dc721530ea1b6ea276f93071be4e6f451a78cc66c30470e361c95995f27759c69534f70419856f1ba6cfe69478b9207db
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
