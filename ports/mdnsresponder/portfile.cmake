vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple-oss-distributions/mDNSResponder
    REF f783506af3836b39b83fc14115bc2728a49db4b2 #mDNSResponder-1557.140.5.0.1
    SHA512 f5954d3f8ef40790e14d17de4cd861fc7df6900e54affefb8282f080a0bfc8b4ac9d238f2faaea6bb3849b342836e45f3b2cb9361402f89fcdce3c627a2b9b4d
    HEAD_REF main
    PATCHES
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
  SET(BUILD_ARCH "Win32")
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

FIX_VCXPROJ("${SOURCE_PATH}/mDNSWindows/DLL/dnssd.vcxproj")
FIX_VCXPROJ("${SOURCE_PATH}/Clients/DNS-SD.VisualStudio/dns-sd.vcxproj")

vcpkg_build_msbuild(
  PROJECT_PATH "${SOURCE_PATH}/mDNSWindows/mDNSResponder.sln"
  PLATFORM ${BUILD_ARCH}
  TARGET dns-sd
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  file(INSTALL
    "${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Release/dnssd.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
  )
  file(INSTALL
    "${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Debug/dnssd.dll"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
  )
endif()
file(INSTALL
  "${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Release/dnssd.lib"
  DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
)
file(INSTALL
  "${SOURCE_PATH}/mDNSWindows/DLL/${BUILD_ARCH}/Debug/dnssd.lib"
  DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
)
file(INSTALL
  "${SOURCE_PATH}/mDNSShared/dns_sd.h"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)
vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
