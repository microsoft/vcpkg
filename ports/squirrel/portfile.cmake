vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO albertodemichelis/squirrel
    HEAD_REF master
    REF c02bf2dfd599a0b99b814d486512a3ee934667f1
    SHA512 a2a487c2430b0076ed0c62eb658b8038a1726138ec30a47fe36246b80e4bb325b853c54889b0834771fc01a3518a51f6982801853cdd6f348eefc85aaaa3e6fe
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "interpreter" BUILD_SQ
)

if(BUILD_SQ)
    set(SQ_DISABLE_INTERPRETER NO)
else()
    set(SQ_DISABLE_INTERPRETER YES)
endif()

message("MARTY")
message("-DSQ_DISABLE_INTERPRETER=${SQ_DISABLE_INTERPRETER}")
message("${FEATURE_OPTIONS}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISABLE_DYNAMIC=${DISABLE_DYNAMIC}
        -DDISABLE_STATIC=${DISABLE_STATIC}
        -DSQ_DISABLE_INTERPRETER=${SQ_DISABLE_INTERPRETER}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/squirrel)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_SQ)
    if(BUILD_STATIC)
        message(STATUS "Copying sq tool")
        vcpkg_copy_tools(
            TOOL_NAMES sq
            AUTO_CLEAN
        )
    elseif(BUILD_DYNAMIC)
        message(STATUS "Copying sq and sq_static tool")
        vcpkg_copy_tools(
            TOOL_NAMES sq sq_static
            AUTO_CLEAN
        )
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
