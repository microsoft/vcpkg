if(NOT TEST_DIR)
    message(FATAL_ERROR "Pass -DTEST_DIR=<empty directory>.")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-android-sdk.cmake")
set(sdk "${TEST_DIR}/sdk")
set(platform "${sdk}/platforms/android-37.2")
set(private_sdk "${TEST_DIR}/private")

if(TEST_INVALID)
    z_vcpkg_qt_android_gradle_prepare_sdk(result "${sdk}" android-37.2 "${private_sdk}")
    message(FATAL_ERROR "Invalid metadata was accepted")
endif()

file(MAKE_DIRECTORY "${platform}" "${sdk}/build-tools/37.0.0")
file(WRITE "${platform}/android.jar" "test")
file(WRITE "${platform}/source.properties"
    "AndroidVersion.ApiLevel=37.2\nAndroidVersion.ExtensionLevel=24\nAndroidVersion.IsBaseSdk=true\nPkg.Revision=2\n")
file(WRITE "${sdk}/build-tools/37.0.0/test" "test")
z_vcpkg_qt_android_gradle_prepare_sdk(result "${sdk}" android-37.2 "${private_sdk}")
if(NOT result STREQUAL private_sdk OR EXISTS "${platform}/package.xml"
   OR NOT EXISTS "${private_sdk}/build-tools/37.0.0/test")
    message(FATAL_ERROR "Private SDK was not created correctly")
endif()
file(READ "${private_sdk}/platforms/android-37.2/package.xml" metadata)
if(NOT metadata MATCHES "<api-level>37\\.2</api-level>"
   OR NOT metadata MATCHES "<extension-level>24</extension-level>")
    message(FATAL_ERROR "Incorrect platform metadata: ${metadata}")
endif()

file(WRITE "${platform}/package.xml" "existing")
z_vcpkg_qt_android_gradle_prepare_sdk(result "${sdk}" android-37.2 "${TEST_DIR}/unused")
if(NOT result STREQUAL sdk OR EXISTS "${TEST_DIR}/unused")
    message(FATAL_ERROR "Existing package metadata was not preserved")
endif()
z_vcpkg_qt_android_gradle_prepare_sdk(result "${sdk}" android-36 "${TEST_DIR}/unused")
if(NOT result STREQUAL sdk OR EXISTS "${TEST_DIR}/unused")
    message(FATAL_ERROR "An integer platform was unnecessarily copied")
endif()

file(REMOVE "${platform}/package.xml")
file(WRITE "${platform}/source.properties" "AndroidVersion.ApiLevel=37.1\n")
execute_process(
    COMMAND "${CMAKE_COMMAND}" "-DTEST_DIR=${TEST_DIR}" -DTEST_INVALID=ON -P "${CMAKE_CURRENT_LIST_FILE}"
    RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE output
)
if(status EQUAL 0 OR NOT output MATCHES "Cannot reconstruct metadata")
    message(FATAL_ERROR "Invalid platform metadata was not rejected: ${output}")
endif()
