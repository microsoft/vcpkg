block(PROPAGATE VCToolkit_VERSION VCToolkit_REDIST_VERSION)

  set(to_skip_msi
    "ClickOnce"
    "CoreEditorFonts"
    "Microsoft.IntelliTrace.ProfilerProxy.Msi"
    "MinShell"
    "GitHubProtocolHandler"
    "VsWebProtocolSelector"
    "FileHandler"
    "RuntimeDebug.14,chip=x86"
    "HTMLHelpWorkshop"
    "Setup.Configuration"
    "Setup.WMIProvider"
    "Debugger.Script.Msi"
    "TestTools"
    "sqllocaldb"
    "VisualStudio.Community.Msi"
  )
  list(JOIN to_skip_msi "|" to_skip_regex)

  set(to_skip_regex "(${to_skip_regex})")

  set(VCToolkit_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_toolkit.cmake")
  set(prefix VCToolkit)
  
  set(vsix_installers "")
  set(msi_installers "")
  foreach(item IN LISTS VCToolkit_FILES)
    if("${item}" MATCHES "${to_skip_regex}" OR "${${prefix}_${item}_FILENAME}" MATCHES "${to_skip_regex}")
      message(STATUS "Skipping '${${prefix}_${item}_FILENAME}'")
      continue()
    endif()
    vcpkg_download_distfile(
        ${prefix}_${item}_DOWNLOAD
        URLS "${${prefix}_${item}_URL}"
        FILENAME "VS-${VERSION}/VS/${${prefix}_${item}_FILENAME}"
        SHA512 "${${prefix}_${item}_SHA512}"
    )
    if(${prefix}_${item}_FILENAME MATCHES ".vsix$")
      list(APPEND vsix_installers "${item}")
    endif()
    if(${prefix}_${item}_FILENAME MATCHES ".msi$")
      list(APPEND msi_installers "${item}")
    endif()
  endforeach()

  set(counter 0)
  foreach(item IN LISTS vsix_installers)
      math(EXPR counter "${counter} + 1")
      message(STATUS "Extracting '${item}' : ${${prefix}_${item}_DOWNLOAD}")
      vcpkg_execute_required_process(
        COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/extract-vsix.ps1" "-VsixFile" "${${prefix}_${item}_DOWNLOAD}" "-ExtractTo" "${vs_base_dir}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "extract_toolkit_${counter}.log"
      )
  endforeach()

  foreach(item IN LISTS msi_installers)
  message(STATUS "Extracting '${item}' to WinSDK : ${${prefix}_${item}_DOWNLOAD}")
    vcpkg_extract_with_lessmsi(
        MSI "${${prefix}_${item}_DOWNLOAD}"
        DESTINATION "${installFolderSdk}"
    )
  endforeach()

  file(COPY "${installFolderSdk}/System64/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

  file(COPY  "${installFolderSdk}/ProgramFilesFolder/" DESTINATION "${installFolderSdk}")
  file(COPY  "${installFolderSdk}/Program Files/" DESTINATION "${installFolderSdk}")

  file(REMOVE_RECURSE
    "${installFolderSdk}/Program Files"
    "${installFolderSdk}/ProgramFilesFolder"
    "${installFolderSdk}/System64"
  )

  file(COPY_FILE "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.v143.default.txt" "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt")

  file(STRINGS "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCRedistVersion.default.txt" VCToolkit_REDIST_VERSION)
  file(STRINGS "${vs_base_dir}/VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt" VCToolkit_VERSION)

  z_vcpkg_apply_patches(
    SOURCE_PATH "${vs_base_dir}"
    PATCHES
      patches/adjust_vcvars_1.patch
      patches/adjust_vcvars_2.patch
  )
endblock()
