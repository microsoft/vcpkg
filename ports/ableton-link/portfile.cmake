#header-only library
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ableton/link
    REF "Link-${VERSION}"
    SHA512 21ab3f47b1b2a7961cae238ca846adf0190341e8379a33938824acc49d3b95d8823b61bc321b1dfcbb3864f740425ac81d8c5c581e882394e1edac230f4c34e4
    HEAD_REF master
    PATCHES
        replace_local_asiostandalone_by_vcpkg_asio.patch
        replace_asiosdk_download_by_vcpkg_asiosdk.patch
        replace_local_catch_by_vcpkg_catch2.patch
        no-werror.patch
        fix_android_build.patch
)

# Note that the dependencies ASIO and ASIOSDK are completely different things:
# -ASIO (ASyncronous IO) is a cross-platform C++ library for network and low-level I/O programming
# -ASIOSDK is the SDK for the Steinberg ASIO (Audio Stream Input/Output) driver, for professional Windows audio applications

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "discoverytest"           LinkDiscoveryTest
    "coretest"                LinkCoreTest
    "hut"                     LinkHut
    "hutsilent"               LinkHutSilent
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ci")
file(REMOVE_RECURSE "${SOURCE_PATH}/modules")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")

set(NEED_CATCH2 OFF)
if ("coretest" IN_LIST FEATURES)
    set(NEED_CATCH2 ON)
endif()
if ("discoverytest" IN_LIST FEATURES)
    set(NEED_CATCH2 ON)
endif()

set(NEED_ASIOSDK OFF)
if ("hut" IN_LIST FEATURES)
  if(VCPKG_TARGET_IS_WINDOWS)
    # Need Steinberg ASIO audio driver SDK (only this low-latency audio driver makes the developer tool 'hut' useful on Windows)
    set(NEED_ASIOSDK ON)
  endif()
endif()
    
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS    
        -DNEED_CATCH2=${NEED_CATCH2}
        -DLINK_BUILD_ASIO=${NEED_ASIOSDK}
        ${FEATURE_OPTIONS}
)

# Helper function to build and install helper executables
function(install_test_executable FEATURE_NAME TARGET_NAME)
    if(${FEATURE_NAME} IN_LIST FEATURES)
        vcpkg_cmake_build(TARGET ${TARGET_NAME})
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/${TARGET_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        if(NOT VCPKG_BUILD_TYPE)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/${TARGET_NAME}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
        endif()
    endif()
endfunction()

# Install test executables
install_test_executable("coretest" "LinkCoreTest")
install_test_executable("discoverytest" "LinkDiscoveryTest")
install_test_executable("hut" "LinkHut")
install_test_executable("hutsilent" "LinkHutSilent")

# We must not correct the CMake include path before build
file(READ "${SOURCE_PATH}/cmake_include/ConfigureAbletonLink.cmake" CONFIG_CONTENT)
string(REPLACE "\${PATH_TO_LINK}/include/ableton/Link.hpp" "\${PATH_TO_LINK}/../../include/ableton/Link.hpp" CONFIG_CONTENT "${CONFIG_CONTENT}")
string(REPLACE "\${PATH_TO_LINK}/include" "\${PATH_TO_LINK}/../../include/ableton" CONFIG_CONTENT "${CONFIG_CONTENT}")
file(WRITE "${SOURCE_PATH}/cmake_include/ConfigureAbletonLink.cmake" "${CONFIG_CONTENT}")

file(INSTALL "${SOURCE_PATH}/AbletonLinkConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/abletonlink")
file(INSTALL "${SOURCE_PATH}/cmake_include/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/abletonlink/cmake_include/")
file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" PATTERN "CMakeLists.txt" EXCLUDE)
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
