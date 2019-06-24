include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mohabouje/WinToast
  REF v1.2.0
  SHA512 d8bd44439100772929eb8a4eb4aebfd66fa54562c838eb4c081a382dc1d73c545faa6d9675e320864d9b533e4a0c4a673e44058c7f643ccd56ec90830cdfaf45
  HEAD_REF master
)

# Install source files
file(INSTALL ${SOURCE_PATH}/src/wintoastlib.cpp
     ${SOURCE_PATH}/src/wintoastlib.h
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
