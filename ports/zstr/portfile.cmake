vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateidavid/zstr
  REF v1.0.4
  SHA512 148dd7741747917d826f0caf291730e14317c700961bec6ae360c1f6a3988d5db555c36428c9641fba3cd76a63b5880dce6b2af47a4388c5451bddce45c39944
  HEAD_REF master
)

# Install source files
file(INSTALL ${SOURCE_PATH}/src/strict_fstream.hpp
     ${SOURCE_PATH}/src/zstr.hpp
     ${SOURCE_PATH}/src/zstr_make_unique_polyfill.h
     DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Install usage
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
