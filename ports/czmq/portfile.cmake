vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/czmq
    REF v4.2.1
    SHA512 65a21f7bd5935b119e1b24ce3b2ce8462031ab7c9a4ba587bb99fe618c9f8cb672cfa202993ddd79e0fb0f154ada06560b79a1b4f762fcce8f88f2f450ecee01
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

foreach(_cmake_module
    Findlibcurl.cmake
    Findlibmicrohttpd.cmake
    Findlibzmq.cmake
    Findlz4.cmake
    Finduuid.cmake
)
    file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}
        DESTINATION ${SOURCE_PATH}
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        draft   ENABLE_DRAFTS
        curl    CZMQ_WITH_LIBCURL
        httpd   CZMQ_WITH_LIBMICROHTTPD
        lz4     CZMQ_WITH_LZ4
        uuid    CZMQ_WITH_UUID
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCZMQ_BUILD_SHARED=${BUILD_SHARED}
        -DCZMQ_BUILD_STATIC=${BUILD_STATIC}
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})
endif()

vcpkg_fixup_pkgconfig()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_copy_tools(TOOL_NAMES zmakecert AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove headers with "common" names that conflict with other packages which aren't intended to be installed
# See https://github.com/zeromq/czmq/issues/2197
foreach(FILE readme.txt sha1.h sha1.inc_c slre.h slre.inc_c zgossip_engine.inc zgossip_msg.h zhash_primes.inc zsock_option.inc)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/${FILE}")
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/czmq_library.h
        "if defined CZMQ_STATIC"
        "if 1 //if defined CZMQ_STATIC"
    )
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
