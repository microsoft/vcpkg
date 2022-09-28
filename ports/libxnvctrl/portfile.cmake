vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO NVIDIA/nvidia-settings
  REF 243def9854b840f25d1b7b4e19f6cdafed5af581
  SHA512 6510b8fabecd46c13d71be954f866fe257328f5cf30ed9ba18bfc6b700836028b8174b1e1d276c714fd961bffdd13d1cc017b07c3de574b491dcd27c840a132a
  HEAD_REF master
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/src/libXNVCtrl")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/src/libXNVCtrl"
    OPTIONS --trace-expand #"-DNVIDIA_VERSION=515.76"
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
