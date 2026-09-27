vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO VirusTotal/yara
  REF "v${VERSION}"
  SHA512 12bbe1bebb6d51f7ae90ad6a725bdb096f3e884b757913e9ba37bfa1557bced32ef56895eb358af5f3165890336be57dc51e9fe2ad672c1e523cb30e00483c86
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

set(
    copyright_files
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/libyara/modules/pe/authenticode-parser/authenticode.c"
)
if("dotnet" IN_LIST FEATURES)
    vcpkg_install_copyright(
        FILE_LIST
            ${copyright_files}
            "${SOURCE_PATH}/libyara/modules/dotnet/dotnet.c"
        COMMENT "The .NET module is licensed under Apache-2.0; see https://www.apache.org/licenses/LICENSE-2.0."
    )
else()
    vcpkg_install_copyright(FILE_LIST ${copyright_files})
endif()
