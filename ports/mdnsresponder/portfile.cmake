vcpkg_download_distfile(ARCHIVE
  URLS https://opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-878.270.2.tar.gz
  FILENAME mDNSResponder-878.270.2.tar.gz
  SHA512 dbc1805c757fceb2b37165ad2575e4084447c10f47ddc871f5476e25affd91f5f759662c17843e30857a9ea1ffd25132bc8012737cf22700ac329713e6a3ac0a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
FIX_VCXPROJ("${SOURCE_PATH}/Clients/DNS-SD.VisualStudio/dns-sd.vcxproj")

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH mDNSResponder.sln
    PLATFORM ${BUILD_ARCH}
    TARGET dns-sd
    INCLUDES_SUBPATH mDNSShared
    INCLUDE_INSTALL_DIR "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
