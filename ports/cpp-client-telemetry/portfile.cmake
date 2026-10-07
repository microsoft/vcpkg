# In-repo overlay-port use should build the working tree under review instead of
# a pinned release -- this is what lets local port installs and tests exercise
# the SDK source + manifest together. The registry copy of this port is not under
# the SDK checkout, so it falls back to the pinned release below.
if(DEFINED ENV{MATSDK_VCPKG_SOURCE_DIR})
    set(SOURCE_PATH "$ENV{MATSDK_VCPKG_SOURCE_DIR}")
    if(NOT EXISTS "${SOURCE_PATH}/CMakeLists.txt")
        message(FATAL_ERROR
            "MATSDK_VCPKG_SOURCE_DIR is set to '${SOURCE_PATH}', but no CMakeLists.txt "
            "was found there. It must point to a cpp_client_telemetry source checkout.")
    endif()
    message(STATUS "cpp-client-telemetry: building local source $ENV{MATSDK_VCPKG_SOURCE_DIR} (MATSDK_VCPKG_SOURCE_DIR is set)")
else()
    get_filename_component(_matsdk_overlay_source "${CURRENT_PORT_DIR}/../../.." ABSOLUTE)
endif()

if(NOT DEFINED SOURCE_PATH
   AND EXISTS "${_matsdk_overlay_source}/CMakeLists.txt"
   AND EXISTS "${_matsdk_overlay_source}/lib/CMakeLists.txt"
   AND EXISTS "${_matsdk_overlay_source}/tools/ports/cpp-client-telemetry/portfile.cmake")
    set(SOURCE_PATH "${_matsdk_overlay_source}")
    message(STATUS "cpp-client-telemetry: building in-repo overlay source ${SOURCE_PATH}")
endif()

if(NOT DEFINED SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO microsoft/cpp_client_telemetry
        REF v3.10.279.1
        SHA512 fc31686bfbe50c3a7f2a287671354579c77de05adab74b350238e02441ede29fff8a5de0621742015547cc0571bb606683b343cd1b85b45fcaac85d31642f430
        HEAD_REF main
    )
endif()

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
      "newer SDK release, or set MATSDK_VCPKG_SOURCE_DIR to a local checkout "
      "that contains the Android Java transport selector.")
  endif()
  if("android-curl-openssl" IN_LIST FEATURES OR "android-curl-mbedtls" IN_LIST FEATURES)
    set(MATSDK_ANDROID_HTTP_CLIENT CURL)
  endif()
endif()

# curl-openssl/curl-mbedtls choose the Linux TLS backend. Android defaults to
# Java/JNI HTTP and uses separate explicit android-curl-* features for its curl
# escape hatch. vcpkg cannot express mutual exclusivity or "exactly one of", so
# validate it here -- but only where curl is actually used, to avoid failing
# legitimate cross-platform manifests on Windows/Apple.
set(_matsdk_http_features "")
if(VCPKG_TARGET_IS_ANDROID)
  set(_matsdk_http_feature_candidates android-curl-openssl android-curl-mbedtls)
else()
  set(_matsdk_http_feature_candidates curl-openssl curl-mbedtls)
endif()
foreach(_matsdk_http_feature ${_matsdk_http_feature_candidates})
  if(_matsdk_http_feature IN_LIST FEATURES)
    list(APPEND _matsdk_http_features ${_matsdk_http_feature})
  endif()
endforeach()
list(LENGTH _matsdk_http_features _matsdk_http_feature_count)
if(VCPKG_TARGET_IS_LINUX OR MATSDK_ANDROID_HTTP_CLIENT STREQUAL "CURL")
  if(_matsdk_http_feature_count GREATER 1)
    message(FATAL_ERROR
      "The curl HTTP backend features are mutually exclusive but multiple were "
      "selected. On Linux, use exactly one of curl-openssl/curl-mbedtls. On "
      "Android, use exactly one of android-curl-openssl/android-curl-mbedtls. "
      "If you added a non-default backend, use the [core,...] form "
      "(default-features=false) so the default curl-openssl feature is dropped.")
  elseif(_matsdk_http_feature_count EQUAL 0 AND VCPKG_TARGET_IS_LINUX)
    # The built-in curl HTTP client requires exactly one TLS backend. The [core,...]
    # form drops the default curl-openssl, so fail fast (with a complete example)
    # rather than letting the SDK CMake fail later on a missing libcurl.
    message(FATAL_ERROR
      "On Linux the built-in curl HTTP client requires exactly one TLS backend "
      "feature, but none was selected. The [core,...] form drops the default "
      "curl-openssl feature, so re-add a curl backend together with a SQLite "
      "backend, e.g. "
      "cpp-client-telemetry[core,curl-mbedtls,system-sqlite] "
      "(or minimal-sqlite in place of system-sqlite).")
  elseif(_matsdk_http_feature_count EQUAL 0)
    message(FATAL_ERROR
      "On Android, MATSDK_ANDROID_HTTP_CLIENT=CURL requires exactly one explicit "
      "Android curl backend feature. Use android-curl-openssl or "
      "android-curl-mbedtls together with a SQLite backend, e.g. "
      "cpp-client-telemetry[core,android-curl-openssl,system-sqlite].")
  endif()
endif()

set(MATSDK_VCPKG_SQLITE_PROVIDER SYSTEM)
if("minimal-sqlite" IN_LIST FEATURES)
  if(NOT MATSDK_OPTION_SOURCE MATCHES "MATSDK_SQLITE_PROVIDER")
    message(FATAL_ERROR
      "The minimal-sqlite feature requires an SDK revision supporting MATSDK_SQLITE_PROVIDER.")
  endif()
  set(MATSDK_VCPKG_SQLITE_PROVIDER MINIMAL)
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
    "Update this port's REF/SHA512 to a newer SDK release, or set "
    "MATSDK_VCPKG_SOURCE_DIR to a local checkout containing that option.")
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
    "REF/SHA512 to a newer SDK release, or set MATSDK_VCPKG_SOURCE_DIR "
    "to a local checkout containing that option.")
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
        -DMATSDK_SQLITE_PROVIDER=${MATSDK_VCPKG_SQLITE_PROVIDER}
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
