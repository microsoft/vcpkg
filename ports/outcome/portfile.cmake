# Outcome is composed of other third party libraries:
#    Outcome
#      <= status-code
#      <= quickcpplib
#         <= byte-lite
#         <= gsl-lite
#         <= Optional
#
# byte-lite and gsl-lite are in vcpkg, but may not be versions
# known to be compatible with Outcome. It has occurred in the
# past that newer versions were severely broken with Outcome.
#
# One can fetch an 'all sources' tarball from
# https://github.com/ned14/outcome/releases which contains
# the exact copy of those third party libraries known to
# have passed Outcome's CI process.

message(WARNING [=[
Outcome depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's and Outcome's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
]=])

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF a86c6b053b86e4fc5d920907b0afb3234bec9336
    SHA512 c282afd7b335fef37ec4c2011bf591d3ffd56872515e8fcbd95714020ab99d141a87a064ecda44bf9308cb4bd1f39977b62303f2cc297918be2f257a36ff5832
    HEAD_REF develop
    PATCHES
      outcome-prune-sources.patch
)

# Outcome needs a copy of QuickCppLib with which to bootstrap its cmake
file(COPY "${CURRENT_INSTALLED_DIR}/include/quickcpplib"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/ned14-internal-quickcpplib/"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/"
)

# Outcome expects status-code to live inside its include directory
file(COPY "${CURRENT_INSTALLED_DIR}/include/status-code/"
    DESTINATION "${SOURCE_PATH}/include/outcome/experimental/status-code/include/"
)
file(COPY "${CURRENT_INSTALLED_DIR}/include/status-code/detail/"
    DESTINATION "${SOURCE_PATH}/include/outcome/experimental/status-code/include/detail/"
)

# Because outcome's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

# Already installed dependencies don't appear on the include path, which Outcome assumes.
string(APPEND VCPKG_CXX_FLAGS " \"-I${CURRENT_INSTALLED_DIR}/include\"")
string(APPEND VCPKG_C_FLAGS " \"-I${CURRENT_INSTALLED_DIR}/include\"")

# Use Outcome's own build process, skipping examples and tests.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -Dquickcpplib_FOUND=1
        -DOUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

if("run-tests" IN_LIST FEATURES)
    vcpkg_build_cmake(TARGET test)
endif()

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/outcome)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
