include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mateidavid/zstr
  REF v1.0.1
  SHA512 616df2394c41038bc8512748a6a699cb45310ff518e75f591c7f957d6ab3da66a384755a6015c3eb588b576940cbff429ff9798985c452b6eda6e22f94dfb264
  HEAD_REF master
)

# Install source files
file(INSTALL ${SOURCE_PATH}/src/strict_fstream.hpp
     ${SOURCE_PATH}/src/zstr.hpp
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
