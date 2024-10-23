vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO VirusTotal/yara
  REF "v${VERSION}"
  SHA512 761f3930117c35d87b0e3be1a5d61a6887006470fdf578164feb1bd56a96b2d85770ab7c3a21258a2781ff3327cb705942f4f0eb959cff4b210f0c7fbec1fc30
  HEAD_REF master
  PATCHES
    # Module elf request new library tlshc(https://github.com/avast/tlshc), the related upstream PR: https://github.com/VirusTotal/yara/pull/1624.
    Disable-module-elf.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuckoo    CUCKOO_MODULE
    dotnet    DOTNET_MODULE
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      ${FEATURE_OPTIONS}
  OPTIONS_DEBUG 
      -DDISABLE_INSTALL_HEADERS=ON 
      -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libyara)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
