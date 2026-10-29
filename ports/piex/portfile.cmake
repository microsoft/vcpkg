vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/piex
  REF 256bd102be288c19b4165e0ecc7097a18c004e92
  SHA512 ae948588a99d586593788c995c3d65a488faaf99b2ab6c51ec39df7e11a42c89454dd505117e90b1f152f6abfc2e3e11f61b0af97e42ecdff0d978934e20f582
  HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
      -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/piex" RENAME copyright)
