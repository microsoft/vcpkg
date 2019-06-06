include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/modp-base64-v2.0.0)
vcpkg_download_distfile(ARCHIVE
  URLS "https://web.archive.org/web/20060620024518/http://modp.com:80/release/base64/modp-base64-v2.0.0.tar.bz2"
  FILENAME "modp-base64-v2.0.0.tar.bz2"
  SHA512 474e20cbbc47f31af5e981a6a9028fcec57e3ae9bb5ba979aa5c5c4cab6f301208fe6f441a0106df4c223d89fb6f18b19ab8812cf9f3c9900e54524e35b45720
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY
  ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
  ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake
  ${CMAKE_CURRENT_LIST_DIR}/libmodpbase64.def
  DESTINATION ${SOURCE_PATH}
)
file(COPY
  ${CMAKE_CURRENT_LIST_DIR}/modp_b64_data.h
  DESTINATION ${SOURCE_PATH}/src
)



vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/modp-base64 RENAME copyright)
