include(vcpkg_common_functions)

vcpkg_download_distfile(ZYDIS_ARCHIVE
  URLS "https://github.com/zyantific/zydis/archive/v3.0.0.zip"
  FILENAME "zydis-3.0.0.zip"
  SHA512 a9a75903553793a19164124e6b6b4f202ef928558ba094ce9e6a9290e4bce4a28a8bb1696b552560a9c093f2774e1f68310ea278b6533867712ba7b3e283d367
)

vcpkg_download_distfile(ZYCORE_ARCHIVE
  URLS "https://github.com/zyantific/zycore-c/archive/ffcc3663200984e6cb54c2879f7b4de3f6112227.zip"
  FILENAME "zycore-c-ffcc3663200984e6cb54c2879f7b4de3f611222.zip"
  SHA512 157ad277462bf71fd111a367c9b192f58f1f8ba364bfdf17cfdec956d14b5b32545299cdd355fd4b7bd7ab07f83b3219c2bb2e9c7b958b857613ed2c5f26afe2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ZYDIS_ARCHIVE}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH ZYCORE_PATH
    ARCHIVE ${ZYCORE_ARCHIVE}
)

file(RENAME ${ZYCORE_PATH} ${SOURCE_PATH}/dependencies/zycore)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ZYDIS_BUILD_SHARED_LIB OFF)
else()
    set(ZYDIS_BUILD_SHARED_LIB ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS "-DZYDIS_BUILD_SHARED_LIB=${ZYDIS_BUILD_SHARED_LIB}"
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXES)
    file(REMOVE ${EXES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
