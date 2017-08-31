include(vcpkg_common_functions)

message(WARNING
  "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location"
  "See https://howardhinnant.github.io/date/tz.html"
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 272d487b3d490126e520b67fe76bbb2e67226c07
  SHA512   59e8ff642d3eb82cb6116a77d4c5e14bbc2ae6bd4019e64a49609b6e46d679c2cb4ccae74807b72223aed18ae015596193919cdb58b011bfb774ff3e29a1d43b
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

set(HEADER "${CURRENT_PACKAGES_DIR}/include/tz.h")
file(READ "${HEADER}" _contents)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "DATE_BUILD_DLL" "1" _contents "${_contents}")
else()
  string(REPLACE "DATE_BUILD_LIB" "1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")


file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
