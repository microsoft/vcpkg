vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple-oss-distributions/mDNSResponder
    REF "mDNSResponder-${VERSION}"
    SHA512 883ecf0a700568555be0d59adbf979a783b1fd84ddd846246acbb63df83774efd87d25d655e74fb8e57832513bd7ae7ed8571b5a5ba4f679fc74cf16b1d24544
    HEAD_REF main
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
  SET(BUILD_ARCH "Win32")
ELSE()
  SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

function(FIX_VCXPROJ VCXPROJ_PATH)
  file(READ ${VCXPROJ_PATH} ORIG)

  if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    string(REPLACE
      "<ConfigurationType>StaticLibrary</ConfigurationType>"
      "<ConfigurationType>DynamicLibrary</ConfigurationType>"
      ORIG "${ORIG}")
  else()
    string(REPLACE
      "<ConfigurationType>DynamicLibrary</ConfigurationType>"
      "<ConfigurationType>StaticLibrary</ConfigurationType>"
      ORIG "${ORIG}")
  endif()

  file(WRITE ${VCXPROJ_PATH} "${ORIG}")
endfunction()

FIX_VCXPROJ("${SOURCE_PATH}/mDNSWindows/DLL/dnssd.vcxproj")
if(${VCPKG_CRT_LINKAGE} STREQUAL "dynamic" AND ${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
    FIX_VCXPROJ("${SOURCE_PATH}/mDNSWindows/DLLStub/DLLStub.vcxproj")
endif()
FIX_VCXPROJ("${SOURCE_PATH}/Clients/DNS-SD.VisualStudio/dns-sd.vcxproj")

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH mDNSWindows/mDNSResponder.sln
    PLATFORM ${BUILD_ARCH}
    TARGET dns-sd
)

file(INSTALL "${SOURCE_PATH}/mDNSShared/dns_sd.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
