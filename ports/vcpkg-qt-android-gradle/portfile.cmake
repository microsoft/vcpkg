set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(VCPKG_CROSSCOMPILING)
    message(FATAL_ERROR "${PORT} is a host-only port!")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/gradle-artifacts.cmake")
if(NOT QT_ANDROID_GRADLE_ARTIFACTS)
    message(FATAL_ERROR "gradle-artifacts.cmake is empty. Regenerate it with generate-artifacts.py.")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(host_os windows)
elseif(VCPKG_TARGET_IS_OSX)
    set(host_os osx)
elseif(VCPKG_TARGET_IS_LINUX)
    set(host_os linux)
else()
    message(FATAL_ERROR "${PORT} does not support this host system.")
endif()

set(share_dir "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_download_distfile(distribution
    URLS "${QT_ANDROID_GRADLE_DISTRIBUTION_URL}"
    FILENAME "${QT_ANDROID_GRADLE_DISTRIBUTION_NAME}.zip"
    SHA512 "${QT_ANDROID_GRADLE_DISTRIBUTION_SHA512}"
)
file(INSTALL "${distribution}" DESTINATION "${share_dir}")

# Offline Maven repository: <repository>|<host os or any>|<maven path>|<sha512>
foreach(artifact IN LISTS QT_ANDROID_GRADLE_ARTIFACTS)
    string(REPLACE "|" ";" artifact "${artifact}")
    list(GET artifact 0 repository)
    list(GET artifact 1 os)
    list(GET artifact 2 path)
    list(GET artifact 3 sha512)
    if(NOT os STREQUAL "any" AND NOT os STREQUAL host_os)
        continue()
    endif()
    string(REPLACE "/" "-" filename "qt-android-gradle-${path}")
    vcpkg_download_distfile(downloaded
        URLS "${QT_ANDROID_GRADLE_REPOSITORY_${repository}}/${path}"
        FILENAME "${filename}"
        SHA512 "${sha512}"
    )
    get_filename_component(directory "${path}" DIRECTORY)
    file(MAKE_DIRECTORY "${share_dir}/m2/${directory}")
    file(COPY_FILE "${downloaded}" "${share_dir}/m2/${path}")
endforeach()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/gradle-artifacts.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/gradle.properties"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-offline-repository.gradle.in"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-qt-android-gradle-inputs.cmake"
    DESTINATION "${share_dir}"
)

file(WRITE "${CURRENT_BUILDTREES_DIR}/copyright"
"This port redistributes, unmodified and only for use at build time:\n"
"- The Gradle build tool distribution ${QT_ANDROID_GRADLE_DISTRIBUTION_NAME},\n"
"  Apache-2.0, https://gradle.org.\n"
"- The Android Gradle Plugin and its dependencies as published on Google Maven,\n"
"  Maven Central and the Gradle Plugin Portal. Licenses vary per artifact (mostly\n"
"  Apache-2.0); see the POM files in share/${PORT}/m2.\n"
)
vcpkg_install_copyright(FILE_LIST "${CURRENT_BUILDTREES_DIR}/copyright")
