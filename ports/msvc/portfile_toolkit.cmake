block(PROPAGATE VCToolkit_VERSION VCToolkit_REDIST_VERSION)
  set(VCToolkit_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_toolkit.cmake")
  set(prefix VCToolkit)

  foreach(item IN LISTS VCToolkit_FILES)
    vcpkg_download_distfile(
        downloaded_file
        URLS "${${prefix}_${item}_URL}"
        FILENAME "VS-${VERSION}/VS/${${prefix}_${item}_FILENAME}"
        SHA512 "${${prefix}_${item}_SHA512}"
    )

    list(APPEND vsix_installers "${downloaded_file}")
  endforeach()

  set(counter 0)
  foreach(item IN LISTS vsix_installers)
      math(EXPR counter "${counter} + 1")
      message(STATUS "Extracting '${item}'")
      vcpkg_execute_required_process(
        COMMAND "${pwsh_exe}" -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/extract-vsix.ps1" "-VsixFile" "${item}" "-ExtractTo" "${CURRENT_PACKAGES_DIR}/VS"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "extract_msbuild_${counter}.log"
      )
  endforeach()
  file(GLOB vc_redist_version_folder LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/VS/VC/Redist/MSVC/*")
  cmake_path(GET vc_redist_version_folder FILENAME VCToolkit_REDIST_VERSION)
  file(GLOB vc_toolkit_version_folder LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/VS/VC/Tools/MSVC/*")
  cmake_path(GET vc_toolkit_version_folder FILENAME VCToolkit_VERSION)
endblock()

#D:\vcpkg_folders\no_msvc\packages\msvc_x64-windows-release\VS\VC\Tools\MSVC\14.41.34120