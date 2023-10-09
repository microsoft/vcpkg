# QuickCppLib is composed of other third party libraries:
#      <= quickcpplib
#         <= byte-lite
#         <= gsl-lite
#         <= Optional
#
# byte-lite and gsl-lite are in vcpkg, but may not be versions
# known to be compatible with QuickCppLib. It has occurred in the
# past that newer versions were severely broken with QuickCppLib.

include("${CURRENT_PORT_DIR}/sha_manifest.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    INVERTED_FEATURES
        polyfill-cxx17 QUICKCPPLIB_REQUIRE_CXX17
        polyfill-cxx20 QUICKCPPLIB_REQUIRE_CXX20
)

if (NOT QUICKCPPLIB_REQUIRE_CXX20)
    message(WARNING [=[
    QuickCppLib and its downstream dependencies Outcome and LLFIO were tested against span-lite version 0.10.3 and byte-lite version 0.3.0. They are not guaranteed to work with newer versions, with failures experienced in the past up-to-and-including runtime crashes. You can pin the versions as verified to work in QuickCppLib's CI in your manifest file by adding:
        "overrides": [
            { "name": "span-lite", "version": "0.10.3" },
            { "name": "byte-lite", "version": "0.3.0" }
        ]
    Do not report issues to upstream without first pinning these previous versions.
    ]=])
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/quickcpplib
    REF ${QUICKCPPLIB_REF}
    SHA512 ${QUICKCPPLIB_SHA512}
    HEAD_REF master
    PATCHES
        quicklib-depheaders.patch
)

# Quickcpplib deploys subsets of the dependency headers into a private subdirectory
if (NOT QUICKCPPLIB_REQUIRE_CXX17)
    file(COPY "${CURRENT_INSTALLED_DIR}/include/nonstd/byte.hpp"
        DESTINATION "${SOURCE_PATH}/include/quickcpplib/byte/include/nonstd")
endif()
if (NOT QUICKCPPLIB_REQUIRE_CXX20)
    file(COPY "${CURRENT_INSTALLED_DIR}/include/nonstd/span.hpp"
        DESTINATION "${SOURCE_PATH}/include/quickcpplib/span-lite/include/nonstd")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH OPT_SOURCE_PATH
    REPO akrzemi1/Optional
    REF ${OPTIONAL_REF}
    SHA512 ${OPTIONAL_SHA512}
    HEAD_REF master
)

file(COPY "${OPT_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/include/quickcpplib/optional")

# Because quickcpplib's deployed files are header-only, the debug build it not necessary
set(VCPKG_BUILD_TYPE release)

# Use QuickCppLib's own build process, skipping examples and tests.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        "-DCMAKE_INSTALL_DATADIR=${CURRENT_PACKAGES_DIR}/share/ned14-internal-quickcpplib"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Doxygen
)

vcpkg_cmake_install()

if (QUICKCPPLIB_REQUIRE_CXX17)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/byte.hpp" "#if QUICKCPPLIB_USE_STD_BYTE" "#if 1")
else ()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/byte.hpp" "#if QUICKCPPLIB_USE_STD_BYTE" "#if 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/byte.hpp" "#include \"byte/include/nonstd/byte.hpp\"" "#include <nonstd/byte.hpp>")
endif()
if (QUICKCPPLIB_REQUIRE_CXX20)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/span.hpp" "#ifdef QUICKCPPLIB_USE_STD_SPAN" "#if 1")
else ()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/span.hpp" "#ifdef QUICKCPPLIB_USE_STD_SPAN" "#if 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/span.hpp" "#elif(_HAS_CXX20 || __cplusplus >= 202002) && __has_include(<span>)" "#elif 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quickcpplib/span.hpp" "#include \"span-lite/include/nonstd/span.hpp\"" "#include <nonstd/span.hpp>")
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME quickcpplib
    CONFIG_PATH lib/cmake/quickcpplib
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
