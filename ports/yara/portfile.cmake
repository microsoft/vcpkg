vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO VirusTotal/yara
  REF "v${VERSION}"
  SHA512 ce8abb01d76d88e413fbbca5e977fb75250bffb26410724e76ddd874fba73bb888efd2898531bd6abf8dc963eb37a314e90c32bbc7a1bb2b1fc1bb4fa92b4773
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

vcpkg_copy_tools(TOOL_NAMES yara yarac AUTO_CLEAN)

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
