include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_IS_WINDOWS)
	message(FATAL_ERROR "${PORT} only supports windows")
endif()

# Check architecture:
if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_ARCH "Win32")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(LIBRE_MAJOR_VER 0)
set(LIBRE_MINOR_VER 6)
set(LIBRE_PATCH_VER 0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO creytiv/re
    REF v${LIBRE_MAJOR_VER}.${LIBRE_MINOR_VER}.${LIBRE_PATCH_VER}
    SHA512 0deab26a5120c21f46969430d6a1a57b3fd0970bded136b49518c3eca308e59fcbceeca5691ea199a9c2b531c684f73d8908d19227540c8ae46fc96370c61781
    HEAD_REF master
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mobile-shell/mosh/files/461099/CommonCrypto.zip"
    FILENAME "CommonCrypto.zip"
    SHA512 9a5b60689ee90ca38a10a564917d92afe99272516be93ee012acc995b7544609cd62270911c58f89f4e1da68ac5838c940239bb6344fe4cea9730d1bcb31e399
)
vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH HEADER_PATH
)

file(GLOB CommonCrypto_Headers ${HEADER_PATH}/*.h)
file(INSTALL ${CommonCrypto_Headers}  DESTINATION ${CURRENT_INSTALLED_DIR}/include/CommonCrypto)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_msbuild(
        USE_VCPKG_INTEGRATION
        PROJECT_PATH ${SOURCE_PATH}/mk/win32/re.vcxproj
        PLATFORM ${BUILD_ARCH}
    )
endif()

file(COPY ${SOURCE_PATH}/${BUILD_ARCH}/Release/bin/re-win32.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/${BUILD_ARCH}/Debug/bin/re-win32.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/${BUILD_ARCH}/Debug/bin/re-win32.pdb DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(GLOB libre_Headers ${SOURCE_PATH}/include/*.h)
file(INSTALL ${libre_Headers}  DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/docs/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
