vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cpp_client_telemetry
    REF v3.10.279.1
    SHA512 fc31686bfbe50c3a7f2a287671354579c77de05adab74b350238e02441ede29fff8a5de0621742015547cc0571bb606683b343cd1b85b45fcaac85d31642f430
    HEAD_REF main
    PATCHES
        fix-apple-package-dependencies.patch
)

file(READ "${SOURCE_PATH}/CMakeLists.txt" MATSDK_OPTION_SOURCE)
if(EXISTS "${SOURCE_PATH}/cmake/MatsdkOptions.cmake")
  file(READ "${SOURCE_PATH}/cmake/MatsdkOptions.cmake" MATSDK_OPTIONS_CMAKE)
  string(APPEND MATSDK_OPTION_SOURCE "\n${MATSDK_OPTIONS_CMAKE}")
endif()

# Determine if Apple HTTP should be used (no curl needed).
# Note: MATSDK_BUILD_APPLE_HTTP must remain ON for macOS/iOS because the vcpkg.json
# curl dependency is excluded on these platforms.
set(MATSDK_BUILD_APPLE_HTTP OFF)
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
  set(MATSDK_BUILD_APPLE_HTTP ON)
endif()

set(MATSDK_APPLE_DEPLOYMENT_OPTIONS)
if(VCPKG_TARGET_IS_IOS)
  list(APPEND MATSDK_APPLE_DEPLOYMENT_OPTIONS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0)
endif()

set(MATSDK_ANDROID_HTTP_CLIENT AUTO)
if(VCPKG_TARGET_IS_ANDROID)
  if(NOT MATSDK_OPTION_SOURCE MATCHES "MATSDK_ANDROID_HTTP_CLIENT")
    message(FATAL_ERROR
      "Android vcpkg builds require a cpp-client-telemetry source revision that "
      "supports MATSDK_ANDROID_HTTP_CLIENT. Update this port's REF/SHA512 to a "
      "newer SDK release containing the Android Java transport selector.")
  endif()
  if("android-curl-openssl" IN_LIST FEATURES OR "android-curl-mbedtls" IN_LIST FEATURES)
    set(MATSDK_ANDROID_HTTP_CLIENT CURL)
  endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(MATSDK_VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(MATSDK_VCPKG_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS
   AND NOT MATSDK_OPTION_SOURCE MATCHES "MATSDK_USE_WININET")
  message(FATAL_ERROR
    "This port revision requires a cpp-client-telemetry source revision that "
    "supports MATSDK_USE_WININET so the Windows transport selection is explicit. "
    "Update this port's REF/SHA512 to a newer SDK release containing that option.")
endif()
set(MATSDK_DEVICE_ID_OPTIONS)
if(MATSDK_OPTION_SOURCE MATCHES "MATSDK_ENABLE_DEVICE_ID")
  set(MATSDK_ENABLE_DEVICE_ID OFF)
  if("device-id" IN_LIST FEATURES)
    set(MATSDK_ENABLE_DEVICE_ID ON)
  endif()
  list(APPEND MATSDK_DEVICE_ID_OPTIONS
    -DMATSDK_ENABLE_DEVICE_ID=${MATSDK_ENABLE_DEVICE_ID})
elseif(NOT "device-id" IN_LIST FEATURES)
  message(FATAL_ERROR
    "Disabling device-ID collection requires a cpp-client-telemetry source "
    "revision that supports MATSDK_ENABLE_DEVICE_ID. Update this port's "
    "REF/SHA512 to a newer SDK release containing that option.")
endif()

set(MATSDK_USE_WININET OFF)
if("wininet" IN_LIST FEATURES)
  set(MATSDK_USE_WININET ON)
endif()

set(MATSDK_NATIVE_FEATURE_OPTIONS)
foreach(_matsdk_feature_option IN ITEMS
    "no-exceptions|MATSDK_DISABLE_EXCEPTIONS"
    "no-logging|MATSDK_DISABLE_LOGGING"
    "android-capi-http-client|MATSDK_ENABLE_CAPI_HTTP_CLIENT")
  string(REPLACE "|" ";" _matsdk_feature_option "${_matsdk_feature_option}")
  list(GET _matsdk_feature_option 0 _matsdk_feature)
  list(GET _matsdk_feature_option 1 _matsdk_option)
  set(_matsdk_enabled OFF)
  if(_matsdk_feature IN_LIST FEATURES)
    if(NOT MATSDK_OPTION_SOURCE MATCHES "${_matsdk_option}")
      message(FATAL_ERROR
        "The ${_matsdk_feature} feature requires an SDK revision supporting ${_matsdk_option}.")
    endif()
    set(_matsdk_enabled ON)
  endif()
  list(APPEND MATSDK_NATIVE_FEATURE_OPTIONS "-D${_matsdk_option}=${_matsdk_enabled}")
endforeach()

set(MATSDK_BUILD_OPTIONS
  -DMATSDK_BUILD_HEADERS=ON
  -DMATSDK_BUILD_LIBRARY=ON
  -DMATSDK_BUILD_TEST_TOOL=OFF
  -DMATSDK_BUILD_UNIT_TESTS=OFF
  -DMATSDK_BUILD_FUNC_TESTS=OFF
  -DMATSDK_BUILD_JNI_WRAPPER=OFF
  -DMATSDK_BUILD_OBJC_WRAPPER=OFF
  -DMATSDK_BUILD_SWIFT_WRAPPER=OFF
  -DMATSDK_BUILD_PACKAGE=OFF
  -DMATSDK_BUILD_APPLE_HTTP=${MATSDK_BUILD_APPLE_HTTP})
set(MATSDK_LEGACY_BUILD_OPTIONS)
foreach(_matsdk_build_option IN LISTS MATSDK_BUILD_OPTIONS)
  string(REGEX REPLACE "^-D([^=]+)=.*$" "\\1" _matsdk_option_name "${_matsdk_build_option}")
  if(NOT MATSDK_OPTION_SOURCE MATCHES "${_matsdk_option_name}")
    string(REPLACE "-DMATSDK_BUILD_" "-DBUILD_" _matsdk_legacy_option "${_matsdk_build_option}")
    list(APPEND MATSDK_LEGACY_BUILD_OPTIONS "${_matsdk_legacy_option}")
  endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${MATSDK_DEVICE_ID_OPTIONS}
        ${MATSDK_NATIVE_FEATURE_OPTIONS}
        ${MATSDK_BUILD_OPTIONS}
        ${MATSDK_LEGACY_BUILD_OPTIONS}
        -DMATSDK_SQLITE_PROVIDER=SYSTEM
        -DMATSDK_ZLIB_PROVIDER=SYSTEM
        -DBUILD_SHARED_LIBS=${MATSDK_VCPKG_BUILD_SHARED_LIBS}
        -DMATSDK_ANDROID_HTTP_CLIENT=${MATSDK_ANDROID_HTTP_CLIENT}
        -DMATSDK_USE_WININET=${MATSDK_USE_WININET}
        -DBUILD_VERSION=${VERSION}
        ${MATSDK_APPLE_DEPLOYMENT_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MSTelemetry CONFIG_PATH lib/cmake/MSTelemetry)

# Remove duplicate headers and empty dirs
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
