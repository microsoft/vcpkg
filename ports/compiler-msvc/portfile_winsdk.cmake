block(PROPAGATE WinSDK_VERSION)
  set(WinSDK_FILES "")
  include("${CMAKE_CURRENT_LIST_DIR}/download_sdk.cmake")

  string(REGEX MATCH "10\\.0\\.[0-9]+" WinSDK_VERSION "${WinSDK_0_FILENAME}")
  set(WinSDK_VERSION "${WinSDK_VERSION}.0")

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
      "arm64-"
      "Intellisense"
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
    string(TOLOWER "${${prefix}_${sdkitem}_FILENAME}" filename_lower)

    if(   "${${prefix}_${sdkitem}_FILENAME}" MATCHES "${to_skip_regex}" AND
      NOT "${${prefix}_${sdkitem}_FILENAME}" MATCHES "${exclude_regex}")
      message(STATUS "Skipping '${${prefix}_${sdkitem}_FILENAME}'")
      continue()
    endif()

    set(filename "${${prefix}_${sdkitem}_FILENAME}")

    vcpkg_download_distfile(
        ${prefix}_${sdkitem}_DOWNLOAD
        URLS "${${prefix}_${sdkitem}_URL}"
        FILENAME "${filename}"
        SHA512 "${${prefix}_${sdkitem}_SHA512}"
    )

    if(${prefix}_${sdkitem}_DOWNLOAD MATCHES ".msi$")
      list(APPEND msi_installers "${${prefix}_${sdkitem}_DOWNLOAD}")
    endif()
  endforeach()

  set(counter 0)
  foreach(msi IN LISTS msi_installers)
    math(EXPR counter "${counter} + 1")

    vcpkg_extract_with_lessmsi(
        MSI "${msi}"
        DESTINATION "${installFolderSdk}"
    )
    
    # Handle extra categories
    foreach(pattern IN LISTS exclude_from_skip)
        if(componentName MATCHES "${pattern}")
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

  set(ucrtsdkprops "${installFolderSdk}/Windows Kits/10/DesignTime/CommonConfiguration/Neutral/uCRT.props")
  file(READ "${ucrtsdkprops}" ucrt_props_content)
  string(REPLACE 
	[[<UCRTContentRoot Condition="'$(UCRTContentRoot)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows Kits\Installed Roots@KitsRoot10)</UCRTContentRoot>]]
	""
	ucrt_props_content
	"${ucrt_props_content}"
  )
  string(REPLACE 
	[[<UCRTContentRoot Condition="'$(UCRTContentRoot)' == ''">$(Registry:HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Kits\Installed Roots@KitsRoot10)</UCRTContentRoot>]]
	[[<UCRTContentRoot Condition="'$(UCRTContentRoot)' == ''">$([MSBUILD]::GetDirectoryNameOfFileAbove('$(MSBUILDTHISFILEDIRECTORY)', 'sdkmanifest.xml'))/</UCRTContentRoot>]]
	ucrt_props_content
	"${ucrt_props_content}"
  )
  file(WRITE "${ucrtsdkprops}" "${ucrt_props_content}")

  # Remove unknown stuff
  file(REMOVE_RECURSE "${installFolderSdk}/Windows App Certification Kit/")
  file(REMOVE_RECURSE "${installFolderSdk}/Microsoft/")
endblock()
