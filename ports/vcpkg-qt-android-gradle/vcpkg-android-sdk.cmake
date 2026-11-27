function(z_vcpkg_qt_android_gradle_prepare_sdk out_var sdk_root platform destination)
    set("${out_var}" "${sdk_root}" PARENT_SCOPE)
    if(NOT platform MATCHES "^android-([0-9]+)\\.([1-9][0-9]*)$")
        return()
    endif()
    set(api_level "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
    set(platform_dir "${sdk_root}/platforms/${platform}")
    if(EXISTS "${platform_dir}/package.xml")
        return()
    endif()
    if(NOT EXISTS "${platform_dir}/android.jar" OR NOT EXISTS "${platform_dir}/source.properties")
        message(FATAL_ERROR "Android platform '${platform_dir}' is missing android.jar or source.properties.")
    endif()

    file(STRINGS "${platform_dir}/source.properties" properties)
    foreach(property IN ITEMS AndroidVersion.ApiLevel AndroidVersion.ExtensionLevel AndroidVersion.IsBaseSdk Pkg.Revision)
        string(REPLACE "." "_" variable "${property}")
        string(REPLACE "." "\\." property_regex "${property}")
        set("${variable}" "")
        foreach(line IN LISTS properties)
            if(line MATCHES "^${property_regex}=(.*)$")
                set("${variable}" "${CMAKE_MATCH_1}")
            endif()
        endforeach()
    endforeach()
    if(NOT AndroidVersion_ApiLevel STREQUAL api_level
       OR NOT AndroidVersion_ExtensionLevel MATCHES "^[0-9]+$"
       OR NOT AndroidVersion_IsBaseSdk MATCHES "^(true|false)$"
       OR NOT Pkg_Revision MATCHES "^[0-9]+$")
        message(FATAL_ERROR "Cannot reconstruct metadata for Android platform '${platform_dir}' from source.properties.")
    endif()

    file(MAKE_DIRECTORY "${destination}/platforms")
    file(COPY "${platform_dir}" DESTINATION "${destination}/platforms")
    foreach(directory IN ITEMS build-tools platform-tools licenses)
        if(EXISTS "${sdk_root}/${directory}")
            file(COPY "${sdk_root}/${directory}" DESTINATION "${destination}")
        endif()
    endforeach()
    file(WRITE "${destination}/platforms/${platform}/package.xml"
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<repo:repository xmlns:repo=\"http://schemas.android.com/repository/android/common/02\"
                 xmlns:sdk=\"http://schemas.android.com/sdk/android/repo/repository2/04\"
                 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">
  <localPackage path=\"platforms;${platform}\">
    <type-details xsi:type=\"sdk:platformDetailsType\">
      <api-level>${api_level}</api-level>
      <extension-level>${AndroidVersion_ExtensionLevel}</extension-level>
      <base-extension>${AndroidVersion_IsBaseSdk}</base-extension>
    </type-details>
    <revision><major>${Pkg_Revision}</major></revision>
    <display-name>Android SDK Platform ${api_level}</display-name>
  </localPackage>
</repo:repository>
")
    message(STATUS "Using a private Android SDK for Gradle: ${destination}")
    set("${out_var}" "${destination}" PARENT_SCOPE)
endfunction()
