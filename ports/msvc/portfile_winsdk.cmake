block(PROPAGATE WinSDK_VERSION)
  set(WinSDK_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_sdk.cmake")

  set(to_skip
      "MsiVal2-x86_en-us"
      "Orca-x86_en-us"
      "Windows App Certification Kit x86-x86_en-us"
      "Windows App Certification Kit x86 \\(OnecoreUAP\\)-x86_en-us"
      "Windows SDK for Windows Store Apps Legacy Tools-x86_en-us"
      "Windows SDK-x86_en-us"
  )

  set(match_skip
      "DirectX"
      "Certification Kit Native Components"
      "Windows App Certification Kit Native Components"
      "Universal CRT Tools"
      "Application Verifier"
  )

  list(APPEND to_skip ${match_skip})

  list(JOIN to_skip "|" to_skip_regex)
  set(to_skip_regex "(${to_skip_regex})")

  set(exclude_from_skip
      "Application Verifier x64 ExternalPackage (DesktopEditions)-x64_en-us"
      "Application Verifier x64 ExternalPackage (OnecoreUAP)-x64_en-us"
  )
  list(JOIN exclude_from_skip "|" exclude_regex)
  set(exclude_regex "(${exclude_regex})")

  set(prefix WinSDK)

  foreach(sdkitem IN LISTS WinSDK_FILES)
    set(skip FALSE)
    string(TOLOWER "${${prefix}_${sdkitem}_FILENAME}" filename_lower)

    if(   "${${prefix}_${sdkitem}_FILENAME}" MATCHES "${to_skip_regex}" AND 
      NOT "${${prefix}_${sdkitem}_FILENAME}" MATCHES "${exclude_regex}")
      message(STATUS "Skipping '${${prefix}_${sdkitem}_FILENAME}'")
      continue()
    endif()

    set(filename "${${prefix}_${sdkitem}_FILENAME}")
    if(NOT "${filename_lower}" MATCHES "winsdk(installer|setup)")
      string(PREPEND filename "Installers/")
    endif()

    vcpkg_download_distfile(
        downloaded_file
        URLS "${${prefix}_${sdkitem}_URL}"
        FILENAME "VS-${VERSION}/WinSDK/${filename}"
        SHA512 "${${prefix}_${sdkitem}_SHA512}"
    )

    if(downloaded_file MATCHES ".msi$")
      list(APPEND msi_installers "${downloaded_file}")
    endif()
  endforeach()

  set(installFolderSdk "${CURRENT_PACKAGES_DIR}/WinSDK")

  set(counter 0)
  foreach(msi IN LISTS msi_installers)
    math(EXPR counter "${counter} + 1")

    vcpkg_extract_with_lessmsi(
        MSI "${msi}"
        DESTINATION "${installFolderSdk}"
    )
    
    # Handle extra categories
    foreach(pattern IN LISTS exclude_from_skip)
        if(skip AND componentName MATCHES "${pattern}")
            file(GLOB_RECURSE catFiles "${installLocation}/*.cat")
            set(catalogsPath "${installFolderSdk}/Program Files/Windows Kits/10/Catalogs")
            file(MAKE_DIRECTORY "${catalogsPath}")
            foreach(catFile IN LISTS catFiles)
                file(COPY "${catFile}" DESTINATION "${catalogsPath}")
            endforeach()
        endif()
    endforeach()
    
    # Handle specific component
    if(componentName MATCHES "WindowsAppCertificationKitNativeComponents-x64_en-us")
        set(kitsPath "${installFolderSdk}/Windows Kits")
        file(MAKE_DIRECTORY "${kitsPath}")
        file(COPY "${installLocation}/Windows Kits" DESTINATION "${kitsPath}")
    endif()
  endforeach()

  # Remove unknown stuff
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/WinSDK/Windows App Certification Kit/")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/WinSDK/Microsoft/")
endblock()
