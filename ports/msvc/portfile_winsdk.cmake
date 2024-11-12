block()
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
    cmake_path(GET msi STEM LAST_ONLY componentName)
    cmake_path(GET msi FILENAME filename)
    math(EXPR counter "${counter} + 1")
  
    message(STATUS "Extracting '${componentName}'")
    string(REPLACE " " "" componentName "${componentName}")
    set(installLocation "${CURRENT_BUILDTREES_DIR}/sdk")
    
    # Create the install location directory
    file(MAKE_DIRECTORY "${installLocation}")
    cmake_path(NATIVE_PATH installLocation NORMALIZE installLocation)
    cmake_path(NATIVE_PATH msi NORMALIZE msi)
    
    # Extract the MSI file
    cmake_path(NATIVE_PATH msi msi_native)
    vcpkg_execute_required_process(
        COMMAND "${LESSMSI}" x "${msi_native}"
        WORKING_DIRECTORY "${installLocation}"
        LOGNAME "lessmsi-${componentName}_cmake.log"
    )
    cmake_path(GET msi FILENAME packstem)
    string(REPLACE ".msi" "" packstem "${packstem}")
    #vcpkg_execute_required_process(
    #    COMMAND msiexec /a "${msi}" /lvoicewarmupx "msiexec_${componentName}.log" /quiet /qn "TARGETDIR=${installLocation}"
    #    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    #    LOGNAME "msiexec_${componentName}_cmake.log"
    #)
    
    # Remove the MSI file from the install location
    #file(REMOVE "${installLocation}/${filename}")
    
    # Check if the install location has files or directories
    #file(GLOB filesAndDirs "${installLocation}/${packstem}/*")
    #if(NOT filesAndDirs)
    #    message(STATUS "Installer had no files or dirs to extract")
    #endif()
    
    # Copy the extracted files to the SDK install folder
    if(EXISTS "${installLocation}/${packstem}/SourceDir/")
        file(COPY "${installLocation}/${packstem}/SourceDir/" DESTINATION "${installFolderSdk}/")
    else()
        message(STATUS "Installer had no files or dirs to extract")
        message(STATUS "Skipping '${componentName}'")
    endif()
    
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
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/WinSDK/Microsoft SDKs/")
endblock()
