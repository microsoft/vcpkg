vcpkg_download_distfile(ARCHIVE
  URLS https://opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-765.30.11.tar.gz
  FILENAME mDNSResponder-765.30.11.tar.gz
  SHA512 dfdea663ec1089058c2225ede13d70241dfec8311ff7fb8d29c8d386f5077a4104455d78f8777496cce96b8ff289b73ed1aec2bf65c52154b866fc1b7675ef90
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
  SET(BUILD_ARCH "Win32")
ELSEIF(TRIPLET_SYSTEM_ARCH MATCHES "arm")
  MESSAGE(FATAL_ERROR " ARM is currently not supported.")
ELSE()
  SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

function(FIX_VCXPROJ VCXPROJ_PATH)
  file(READ ${VCXPROJ_PATH} ORIG)
  if(${VCPKG_CRT_LINKAGE} STREQUAL "dynamic")
    string(REGEX REPLACE
      "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>"
      "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>"
      ORIG "${ORIG}")
    string(REGEX REPLACE
      "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>"
      "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>"
      ORIG "${ORIG}")
  else()
    string(REGEX REPLACE
      "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>"
      "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>"
      ORIG "${ORIG}")
    string(REGEX REPLACE
      "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>"
      "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>"
      ORIG "${ORIG}")
  endif()
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
  
  string(REPLACE
    "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
    "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    ORIG "${ORIG}")
  file(WRITE ${VCXPROJ_PATH} "${ORIG}")
endfunction()

FIX_VCXPROJ(${SOURCE_PATH}/mDNSWindows/DLL/dnssd.vcxproj)
FIX_VCXPROJ(${SOURCE_PATH}/Clients/DNS-SD.VisualStudio/dns-sd.vcxproj)

vcpkg_build_msbuild(
  PROJECT_PATH ${SOURCE_PATH}/mDNSResponder.sln
  PLATFORM ${BUILD_ARCH}
  TARGET dns-sd
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  file(INSTALL
    ${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Release/dnssd.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
  )
  file(INSTALL
    ${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Debug/dnssd.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
  )
endif()
file(INSTALL
  ${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Release/dnssd.lib
  DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
  ${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Debug/dnssd.lib
  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
  ${SOURCE_PATH}/mDNSShared/dns_sd.h
  DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
  ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/mdnsresponder/copyright
)
vcpkg_copy_pdbs()
