include(vcpkg_common_functions)

message(WARNING
  "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location"
  "See https://howardhinnant.github.io/date/tz.html"
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 2.3
  SHA512 d629f2fb1403913ed276bec9c6fd72b8eb16067663e188b7be0c22c2621332f5b46f1eed166874b7a27f90b08fca8a5509b49f395611a1af5ca73385953e3abe
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
