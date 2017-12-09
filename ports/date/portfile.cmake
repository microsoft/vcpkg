include(vcpkg_common_functions)

message(WARNING
  "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location"
  "See https://howardhinnant.github.io/date/tz.html"
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF c286981b3bf83c79554769df68b27415cee68d77
  SHA512 226e2cbc2598fbbe3a451664b017ab5b4314a682a9303268bd531931ea23baa4c9677c4433a87dbbc4a7d960dcfad1fcb632ac430d5d81c9909bcc567cf7eadf
  HEAD_REF master
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
  string(REPLACE "DATE_BUILD_DLL" "1" _contents "${_contents}")
else()
  string(REPLACE "DATE_BUILD_LIB" "1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")


file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
