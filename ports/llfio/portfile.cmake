if ("polyfill-cxx20" IN_LIST FEATURES)
    message(WARNING [=[
    LLFIO depends on Outcome which depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's, Outcome's and LLFIO's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
    ]=])
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/llfio
    REF aa2be6c0db56b4164837d3bc20938785dea7419d
    SHA512 37ebb7ad87cd5c6eedad25221ee34809587fd18245b3c6af56fa64f165d46e826310c66f61ad7e1ab6bfab9cf9331dc51ea08389b9adea11b1225f3fc63f0240
    HEAD_REF develop
    PATCHES
)

vcpkg_from_github(
    OUT_SOURCE_PATH NTKEC_SOURCE_PATH
    REPO ned14/ntkernel-error-category
    REF 278b90e2c7bb07e70d155ad8c7b904188280b7dc
    SHA512 a0e35fb196085012da0299d0dc456e70f4d4044144bc720f24c9a0ac1483724c137ef89740dc65821d135ca070650775a6802c0b21b24703a93d4ef60a30ffdb
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS LLFIO_FEATURE_OPTIONS
    FEATURES
      status-code LLFIO_USE_EXPERIMENTAL_SG14_STATUS_CODE
)

# LLFIO expects ntkernel-error-category to live inside its include directory
file(REMOVE_RECURSE "${SOURCE_PATH}/include/llfio/ntkernel-error-category")
file(RENAME "${NTKEC_SOURCE_PATH}" "${SOURCE_PATH}/include/llfio/ntkernel-error-category")

set(extra_config)
# cmake does not correctly set CMAKE_SYSTEM_PROCESSOR when targeting ARM on Windows
if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
  list(APPEND extra_config -DLLFIO_ASSUME_CROSS_COMPILING=ON)
endif()
# setting CMAKE_CXX_STANDARD here to prevent llfio from messing with compiler flags
# the cmake package config requires said C++ standard target transitively via quickcpplib
if ("cxx20" IN_LIST FEATURES)
    list(APPEND extra_config -DCMAKE_CXX_STANDARD=20)
elseif("cxx17" IN_LIST FEATURES)
    list(APPEND extra_config -DCMAKE_CXX_STANDARD=17)
endif()

# quickcpplib parses CMAKE_MSVC_RUNTIME_LIBRARY and cannot support the default crt linkage generator expression from vcpkg
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        list(APPEND extra_config -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$$<$$<CONFIG:Debug>:Debug>DLL)
    else()
        list(APPEND extra_config -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$$<$$<CONFIG:Debug>:Debug>)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dllfio_IS_DEPENDENCY=On
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        ${LLFIO_FEATURE_OPTIONS}
        -DLLFIO_FORCE_OPENSSL_OFF=ON
        -DLLFIO_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCXX_CONCEPTS_FLAGS=
        -DCXX_COROUTINES_FLAGS=
        -DCMAKE_POLICY_DEFAULT_CMP0091=NEW # MSVC <filesystem> detection fails without this
        ${extra_config}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_cmake_build(TARGET install.dl)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_cmake_build(TARGET install.sl)
endif()

if("run-tests" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET test)
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/llfio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if("status-code" IN_LIST FEATURES)
    set(_USAGE_FEATURE "status-code")
else()
    set(_USAGE_FEATURE "error-code")
endif()
file(INSTALL "${CURRENT_PORT_DIR}/usage-${_USAGE_FEATURE}-${VCPKG_LIBRARY_LINKAGE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
