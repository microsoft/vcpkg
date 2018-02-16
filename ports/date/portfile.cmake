include(vcpkg_common_functions)

message(WARNING
  "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location"
  "See https://howardhinnant.github.io/date/tz.html"
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF v2.4
  SHA512 01bcc021ebf9ca0ac88c797896a291ff81834e7fae37323ad20881d3a172963c04d3c7bea0dd37cd945b756ab7f70f0a02edb18a085bf9abf8d8f10056f73f3c
  HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-date.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

set(HEADER "${CURRENT_PACKAGES_DIR}/include/date/tz.h")
file(READ "${HEADER}" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "ifdef DATE_BUILD_DLL" "if 1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
