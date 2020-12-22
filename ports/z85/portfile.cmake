vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO artemkin/z85
  REF v1.0
  SHA512 6b205524b8388c5709ca664a595a4db8fdd24148c5f87ef7ef16d6d6eb60d2c51db0b4ab768fe9ac3e5acf5e3fe1b46ef5b9f5e7f69a53fe40a7e8d25b098479
  HEAD_REF master
)

# Install source files
file(INSTALL ${SOURCE_PATH}/src/z85.h
     ${SOURCE_PATH}/src/z85.c
     ${SOURCE_PATH}/src/z85.hpp
     ${SOURCE_PATH}/src/z85_impl.cpp
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
