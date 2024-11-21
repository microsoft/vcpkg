block(PROPAGATE VCToolkit_VERSION VCToolkit_REDIST_VERSION)
  set(VCToolkit_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_toolkit.cmake")
  set(prefix VCToolkit)
  
  set(vs_base_dir "${CURRENT_PACKAGES_DIR}/VS")

  set(vsix_installers "")
  set(msi_installers "")
  foreach(item IN LISTS VCToolkit_FILES)
    vcpkg_download_distfile(
        downloaded_file
        URLS "${${prefix}_${item}_URL}"
        FILENAME "VS-${VERSION}/VS/${${prefix}_${item}_FILENAME}"
        SHA512 "${${prefix}_${item}_SHA512}"
    )
    
    if(${prefix}_${item}_FILENAME MATCHES ".vsix$")
      list(APPEND vsix_installers "${downloaded_file}")
    endif()
    if(${prefix}_${item}_FILENAME MATCHES ".msi$")
      list(APPEND msi_installers "${downloaded_file}")
    endif()
  endforeach()

  set(counter 0)
  foreach(item IN LISTS vsix_installers)
      math(EXPR counter "${counter} + 1")
      message(STATUS "Extracting '${item}'")
      vcpkg_execute_required_process(
        COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/extract-vsix.ps1" "-VsixFile" "${item}" "-ExtractTo" "${vs_base_dir}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "extract_toolkit_${counter}.log"
      )
  endforeach()

  set(installFolderSdk "${CURRENT_PACKAGES_DIR}/WinSDK")

  foreach(msi IN LISTS msi_installers)
    vcpkg_extract_with_lessmsi(
        MSI "${msi}"
        DESTINATION "${installFolderSdk}"
    )
  endforeach()

  file(COPY "${installFolderSdk}/Program Files/Windows Kits/" DESTINATION "${installFolderSdk}/Windows Kits/")
  file(COPY "${installFolderSdk}/Program Files/Microsoft SDKs/" DESTINATION "${installFolderSdk}")
  file(COPY "${installFolderSdk}/Program Files/Reference Assemblies/" DESTINATION "${installFolderSdk}")

  file(REMOVE_RECURSE "${installFolderSdk}/Program Files")

  file(COPY_FILE "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.v143.default.txt" "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt")

  file(STRINGS "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCRedistVersion.default.txt" VCToolkit_REDIST_VERSION)
  file(STRINGS "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt" VCToolkit_VERSION)
endblock()
