message(WARNING [=[
LLFIO depends on Outcome which depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's, Outcome's and LLFIO's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
]=])


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/llfio
    REF 721503d32fe35dbaa93bde0214ae8cd3799d14b8
    SHA512 b017a0fddcd3e53c22d9863454e7ad4ce364d9e4fa46cd909ceb395df57052b5d4334081a3405e1248452863c451c3174dc7eaab70907dc8d22f4db67930cbd5
    HEAD_REF develop
)

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_from_github(
      OUT_SOURCE_PATH NTKEC_SOURCE_PATH
      REPO ned14/ntkernel-error-category
      REF bbd44623594142155d49bd3ce8820d3cf9da1e1e
      SHA512 589d3bc7bca98ca8d05ce9f5cf009dd98b8884bdf3739582f2f6cbf5a324ce95007ea041450ed935baa4a401b4a0242c181fb6d2dcf7ad91587d75f05491f50e
      HEAD_REF master
  )
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS LLFIO_FEATURE_OPTIONS
    FEATURES
      status-code LLFIO_USE_EXPERIMENTAL_SG14_STATUS_CODE
)

# LLFIO needs a copy of QuickCppLib with which to bootstrap its cmake
file(COPY "${CURRENT_INSTALLED_DIR}/include/quickcpplib"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/ned14-internal-quickcpplib/"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/"
)

# LLFIO expects ntkernel-error-category to live inside its include directory
file(REMOVE_RECURSE "${SOURCE_PATH}/include/llfio/ntkernel-error-category")
if(VCPKG_TARGET_IS_WINDOWS)
  file(RENAME "${NTKEC_SOURCE_PATH}" "${SOURCE_PATH}/include/llfio/ntkernel-error-category")
endif()

# Already installed dependencies don't appear on the include path, which LLFIO assumes.
string(APPEND VCPKG_CXX_FLAGS " \"-I${CURRENT_INSTALLED_DIR}/include\"")
string(APPEND VCPKG_C_FLAGS " \"-I${CURRENT_INSTALLED_DIR}/include\"")

set(extra_config)
# cmake does not correctly set CMAKE_SYSTEM_PROCESSOR when targeting ARM on Windows
if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
  list(APPEND extra_config -DLLFIO_ASSUME_CROSS_COMPILING=On)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -Dquickcpplib_FOUND=1
        -Doutcome_FOUND=1
        ${LLFIO_FEATURE_OPTIONS}
        -DLLFIO_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${extra_config}
)

# LLFIO install assumes that the static library is always built
vcpkg_build_cmake(TARGET _sl)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_build_cmake(TARGET _dl)
endif()

if("run-tests" IN_LIST FEATURES)
    vcpkg_build_cmake(TARGET test)
endif()

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/llfio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if("status-code" IN_LIST FEATURES)
    file(INSTALL "${CURRENT_PORT_DIR}/usage-status-code-${VCPKG_LIBRARY_LINKAGE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
else()
    file(INSTALL "${CURRENT_PORT_DIR}/usage-error-code-${VCPKG_LIBRARY_LINKAGE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
