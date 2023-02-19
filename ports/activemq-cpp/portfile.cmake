set(VERSION 3.9.5)

set(PATCHES )
if (NOT VCPKG_TARGET_IS_LINUX)
    set(PATCHES FunctionLevelLinkingOn.diff)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND PATCHES fix-crt-linkage.patch)
    else()
        list(APPEND PATCHES fix-crt-linkage-dyn.patch)
    endif()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/activemq/activemq-cpp/${VERSION}/activemq-cpp-library-${VERSION}-src.tar.bz2"
    FILENAME "activemq-cpp-library-${VERSION}-src.tar.bz2"
    SHA512 83692d3dfd5ecf557fc88d204a03bf169ce6180bcff27be41b09409b8f7793368ffbeed42d98ef6374c6b6b477d9beb8a4a9ac584df9e56725ec59ceceaa6ae2
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES ${PATCHES}
)

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            "--with-openssl=${CURRENT_INSTALLED_DIR}"
            "--with-apr=${CURRENT_INSTALLED_DIR}/tools/apr"
    )

    vcpkg_install_make()

    file(RENAME "${CURRENT_PACKAGES_DIR}/include/activemq-cpp-${VERSION}/activemq" "${CURRENT_PACKAGES_DIR}/include/activemq")
    file(RENAME "${CURRENT_PACKAGES_DIR}/include/activemq-cpp-${VERSION}/cms" "${CURRENT_PACKAGES_DIR}/include/cms")
    file(RENAME "${CURRENT_PACKAGES_DIR}/include/activemq-cpp-${VERSION}/decaf" "${CURRENT_PACKAGES_DIR}/include/decaf")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/activemq-cpp-${VERSION}")

    vcpkg_copy_pdbs()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/activemqcpp-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/activemqcpp-config" "${CURRENT_INSTALLED_DIR}/debug" "`dirname $0`/../../../..")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/activemqcpp-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    endif()
else()
    set(ACTIVEMQCPP_MSVC_PROJ "${SOURCE_PATH}/vs2010-build/activemq-cpp.vcxproj")

    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ACTIVEMQCPP_SHARED_LIB)

    if (ACTIVEMQCPP_SHARED_LIB)
        set(RELEASE_CONF "ReleaseDLL")
        set(DEBUG_CONF   "DebugDLL")

        set(ACTIVEMQCPP_LIB_PREFFIX )
        set(ACTIVEMQCPP_LIB_SUFFIX d)
        vcpkg_replace_string("${ACTIVEMQCPP_MSVC_PROJ}" ";apr-1.lib" ";libapr-1.lib")
    else()
        set(RELEASE_CONF "Release")
        set(DEBUG_CONF   "Debug")

        set(ACTIVEMQCPP_LIB_PREFFIX lib)
        set(ACTIVEMQCPP_LIB_SUFFIX )
        vcpkg_replace_string("${ACTIVEMQCPP_MSVC_PROJ}" ";libapr-1.lib" ";apr-1.lib")
    endif()

    if (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(BUILD_ARCH "Win32")
    elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(BUILD_ARCH "x64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    string(REPLACE "/" "\\" WIN_SOURCE_PATH "${SOURCE_PATH}")
    vcpkg_replace_string("${ACTIVEMQCPP_MSVC_PROJ}" "ClCompile Include=\"..\\src" "ClCompile Include=\"${WIN_SOURCE_PATH}\\src")
    vcpkg_replace_string("${ACTIVEMQCPP_MSVC_PROJ}" "ClInclude Include=\"..\\src" "ClInclude Include=\"${WIN_SOURCE_PATH}\\src")
    vcpkg_replace_string("${ACTIVEMQCPP_MSVC_PROJ}" "../src/main" "${WIN_SOURCE_PATH}\\src\\main")
    vcpkg_install_msbuild(
         SOURCE_PATH "${SOURCE_PATH}/vs2010-build"
         PROJECT_SUBPATH "activemq-cpp.vcxproj"
         RELEASE_CONFIGURATION ${RELEASE_CONF}
         DEBUG_CONFIGURATION   ${DEBUG_CONF}
         PLATFORM ${BUILD_ARCH}
         USE_VCPKG_INTEGRATION
         ALLOW_ROOT_INCLUDES
         SKIP_CLEAN
    )

    vcpkg_copy_pdbs()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/${ACTIVEMQCPP_LIB_PREFFIX}activemq-cpp.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )

        if (ACTIVEMQCPP_SHARED_LIB)
            file(COPY
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/activemq-cpp.dll"
                DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
            )
            file(COPY
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vs2010-build/${BUILD_ARCH}/${RELEASE_CONF}/activemq-cpp.pdb"
                DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
            )
        endif()
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/${ACTIVEMQCPP_LIB_PREFFIX}activemq-cpp${ACTIVEMQCPP_LIB_SUFFIX}.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )

        if (ACTIVEMQCPP_SHARED_LIB)
            file(COPY
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/activemq-cpp${ACTIVEMQCPP_LIB_SUFFIX}.dll"
                DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
            )
            file(COPY
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/vs2010-build/${BUILD_ARCH}/${DEBUG_CONF}/activemq-cpp${ACTIVEMQCPP_LIB_SUFFIX}.pdb"
                DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
            )
        endif()
    endif()

    file(COPY "${SOURCE_PATH}/src/main/activemq" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN *.h)
    file(COPY "${SOURCE_PATH}/src/main/cms"      DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN *.h)
    file(COPY "${SOURCE_PATH}/src/main/decaf"    DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN *.h)
    vcpkg_clean_msbuild()
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${CURRENT_PORT_DIR}/activemq-cppConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/activemq-cpp")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
