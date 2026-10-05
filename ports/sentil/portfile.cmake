vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sedislab/SENTIL
    REF "v${VERSION}"
    SHA512 109f031b7184b5aafa54ada8052b6831ad4315cc5f6149dae150a46bcf0b6b535d12d001f9be5eb009513f960cb7752f92174eed9f4646a012d09dc8189b7233
    HEAD_REF main
)

# The core is a Rust cdylib, so the release distfile will produce that binary but the cpp will be built from source
if(VCPKG_TARGET_IS_LINUX)
    set(core_bundle "sentil-${VERSION}-linux-x86_64")
    set(core_sha512 d6d7239299f3be5f76cfa7d0b58f23aa56f7dce11df53f01f4bcc12fe3c266aa1e747996634665bbfa171b3bd3101459d55fa0f8caf90c1dc7c370e716752316)
    set(core_binary "libsentil.so")
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(core_bundle "sentil-${VERSION}-macos-arm64")
    set(core_sha512 af19c1b6db08cdb7ffa375ea34361cf16662d305e5e65b9a4d1b2ce0a518f47c223f08b0ae60bba9d4369f2b6427e13a85519870a46ad8ea5e1dcd24446d03f1)
    set(core_binary "libsentil.dylib")
elseif(VCPKG_TARGET_IS_OSX)
    set(core_bundle "sentil-${VERSION}-macos-x86_64")
    set(core_sha512 152437a3ebd7f3ff0bb75b3340504c3c610b2258c1c8a881e274061d5a9166423ba69130d52e41efa6089f4e0a0eae63d29b8e7d8f825d7a4f1189eb339e5ab0)
    set(core_binary "libsentil.dylib")
else()
    set(core_bundle "sentil-${VERSION}-windows-x86_64")
    set(core_sha512 c81f130bff1fdc2eb6672a1ec756f977305fcc16982dbc93692f5dba301bf676362181d30ae752056c866fd74975d934d7d331eb313725c7482c968cc0decba8)
    set(core_binary "sentil.dll")
    # Pushed by upstream and linked
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(CORE_ARCHIVE
    URLS "https://github.com/sedislab/SENTIL/releases/download/v${VERSION}/${core_bundle}.tar.gz"
    FILENAME "${core_bundle}.tar.gz"
    SHA512 "${core_sha512}"
)

vcpkg_extract_source_archive(CORE_PATH
    ARCHIVE "${CORE_ARCHIVE}"
    SOURCE_BASE "${core_bundle}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sentil-cpp"
    OPTIONS
        -DSENTIL_CPP_BUILD_CORE=OFF
        -DSENTIL_CPP_BUILD_TESTS=OFF
        -DSENTIL_CPP_BUILD_EXAMPLES=OFF
        "-DSENTIL_INCLUDE_DIR=${CORE_PATH}/include"
        "-DSENTIL_LIB_DIR=${CORE_PATH}/lib"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME sentilcpp CONFIG_PATH lib/cmake/SentilCpp)

file(INSTALL "${SOURCE_PATH}/sentil-ffi/include/sentil.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PATCHELF)
    set(core_id_command "${PATCHELF}" --set-soname "${core_binary}")
elseif(VCPKG_TARGET_IS_OSX)
    set(core_id_command install_name_tool -id "@rpath/${core_binary}")
endif()

set(core_configs release debug)
if(VCPKG_BUILD_TYPE)
    set(core_configs "${VCPKG_BUILD_TYPE}")
endif()

foreach(config IN LISTS core_configs)
    set(prefix "${CURRENT_PACKAGES_DIR}")
    if(config STREQUAL "debug")
        string(APPEND prefix "/debug")
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        file(INSTALL "${CORE_PATH}/lib/${core_binary}" DESTINATION "${prefix}/bin")
        file(INSTALL "${CORE_PATH}/lib/sentil.dll.lib" DESTINATION "${prefix}/lib")
    else()
        file(INSTALL "${CORE_PATH}/lib/${core_binary}" DESTINATION "${prefix}/lib" USE_SOURCE_PERMISSIONS)
        vcpkg_execute_required_process(
            COMMAND ${core_id_command} "${prefix}/lib/${core_binary}"
            WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
            LOGNAME "library-id-${config}-${TARGET_TRIPLET}"
        )
    endif()
    file(INSTALL "${CORE_PATH}/lib/pkgconfig/sentil.pc" DESTINATION "${prefix}/lib/pkgconfig")
endforeach()

vcpkg_fixup_pkgconfig()

if("release" IN_LIST core_configs)
    set(default_config "Release")
else()
    set(default_config "Debug")
endif()
set(mapped_configs MINSIZEREL RELWITHDEBINFO NOCONFIG)
if(NOT "debug" IN_LIST core_configs)
    list(APPEND mapped_configs DEBUG)
elseif(NOT "release" IN_LIST core_configs)
    list(APPEND mapped_configs RELEASE)
endif()

set(sentil_config "${CURRENT_PACKAGES_DIR}/share/${PORT}/SentilConfig.cmake")
file(WRITE "${sentil_config}" "set(SENTIL_VERSION ${VERSION})\n")
file(APPEND "${sentil_config}" [[
get_filename_component(SENTIL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(SENTIL_INCLUDE_DIR "${SENTIL_PREFIX}/include")

if(NOT TARGET Sentil::sentil)
    add_library(Sentil::sentil SHARED IMPORTED)
    set_property(TARGET Sentil::sentil PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SENTIL_INCLUDE_DIR}")
]])
foreach(mapped IN LISTS mapped_configs)
    file(APPEND "${sentil_config}"
        "    set_property(TARGET Sentil::sentil PROPERTY MAP_IMPORTED_CONFIG_${mapped} ${default_config})\n")
endforeach()
foreach(config IN LISTS core_configs)
    string(TOUPPER "${config}" config_id)
    set(config_prefix [[${SENTIL_PREFIX}]])
    if(config STREQUAL "debug")
        string(APPEND config_prefix "/debug")
    endif()
    file(APPEND "${sentil_config}"
        "    set_property(TARGET Sentil::sentil APPEND PROPERTY IMPORTED_CONFIGURATIONS ${config_id})\n")
    if(VCPKG_TARGET_IS_WINDOWS)
        file(APPEND "${sentil_config}"
            "    set_target_properties(Sentil::sentil PROPERTIES\n"
            "        IMPORTED_LOCATION_${config_id} \"${config_prefix}/bin/${core_binary}\"\n"
            "        IMPORTED_IMPLIB_${config_id} \"${config_prefix}/lib/sentil.dll.lib\")\n")
    else()
        file(APPEND "${sentil_config}"
            "    set_property(TARGET Sentil::sentil PROPERTY IMPORTED_LOCATION_${config_id} \"${config_prefix}/lib/${core_binary}\")\n")
    endif()
endforeach()
file(APPEND "${sentil_config}" "endif()\n")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-APACHE")