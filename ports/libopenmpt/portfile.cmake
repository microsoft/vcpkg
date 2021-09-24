vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OpenMPT/openmpt
  REF 44733ab3d25c187e1f7a2315abdd5e1b723f4609 # libopenmpt-0.5.10
  SHA512 f7767a1e64b16f283788c253a0326c47ca9ae87a437636a7f9e7af584721b870de4104ac0a8a5e43eb85625d263259ef4c67f38034530c1f84dbaaa88393ba77
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
