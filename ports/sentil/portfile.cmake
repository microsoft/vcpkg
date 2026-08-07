vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sedislab/SENTIL
    REF "v${VERSION}"
    SHA512 0df1ba3e3867124dd4d4adebcc3311d156ed8e63e9a1ae2ceff2a038a69b23fc37b922b92b063d2a0d0399cf5f7b1d6797f71a1dff3ce2e38239de317f2cd0e8
    HEAD_REF main
)

# The core is a Rust cdylib, so the release distfile will produce that binary but the cpp will be built from source
if(VCPKG_TARGET_IS_LINUX)
    set(core_bundle "sentil-${VERSION}-linux-x86_64")
    set(core_sha512 42ad31693badb2cf1660dca250be3e6f490fbb6bf93e1d9ede0408db8c11e20d8e316445a74b6c318d6d5f3f85e237fa0405d629492056d954d566486788a0fa)
    set(core_binary "libsentil.so")
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(core_bundle "sentil-${VERSION}-macos-arm64")
    set(core_sha512 464f1e56348e2fb25cc30dd70470ca8551810027e827c6c52d4bd94ea766616515d16e2efe5176e3eb6145a23d44f462b18780acf8456b3d376c373a8a8eeb87)
    set(core_binary "libsentil.dylib")
elseif(VCPKG_TARGET_IS_OSX)
    set(core_bundle "sentil-${VERSION}-macos-x86_64")
    set(core_sha512 2328dd5c1c31a3c5f355122723ccbb293c02010f58ac3019e11687191269e73cfa1fc747544e50ccdb22bf104f5ab0c38a01bc3456a30fc26532cc038daabb8b)
    set(core_binary "libsentil.dylib")
else()
    set(core_bundle "sentil-${VERSION}-windows-x86_64")
    set(core_sha512 f0e2ef0edd5793d53b4b405269e22e1b711f367febe35df0ea0b65ae56f76f41d7490ce6d8ffdcbf87c09ff9a253d497d985e2767eee5fc7562b635222475907)
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