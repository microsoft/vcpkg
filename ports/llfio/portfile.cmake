if (NOT "cxx20" IN_LIST FEATURES)
    message(WARNING [=[
    LLFIO depends on Outcome which depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's, Outcome's and LLFIO's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
    ]=])
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/llfio
    REF 4a117d683b82a2e3e456c2ecc47a99c8406280fa
    SHA512 7880356dbff10664a146a09558ba15f95cf6883ebe8e0af3d392fbd6f86f3455b9b5c8b6c5c1281c8fca93c358fcafd3468ab575eee0b483ec5b136ca59eef04
    HEAD_REF develop
    PATCHES
        # https://github.com/ned14/llfio/issues/83
        # To be removed on next update
        issue-83-fix-backport.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH NTKEC_SOURCE_PATH
    REPO ned14/ntkernel-error-category
    REF bbd44623594142155d49bd3ce8820d3cf9da1e1e
    SHA512 589d3bc7bca98ca8d05ce9f5cf009dd98b8884bdf3739582f2f6cbf5a324ce95007ea041450ed935baa4a401b4a0242c181fb6d2dcf7ad91587d75f05491f50e
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
  list(APPEND extra_config -DLLFIO_ASSUME_CROSS_COMPILING=On)
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
        -DPROJECT_IS_DEPENDENCY=On
        -Dquickcpplib_DIR=${CURRENT_INSTALLED_DIR}/share/quickcpplib
        ${LLFIO_FEATURE_OPTIONS}
        -DLLFIO_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${extra_config}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_cmake_build(TARGET install.dl)
else(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_cmake_build(TARGET install.sl)
endif()

if("run-tests" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET test)
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/llfio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if("status-code" IN_LIST FEATURES)
    file(INSTALL "${CURRENT_PORT_DIR}/usage-status-code-${VCPKG_LIBRARY_LINKAGE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
else()
    file(INSTALL "${CURRENT_PORT_DIR}/usage-error-code-${VCPKG_LIBRARY_LINKAGE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
