vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO realm/realm-cpp
        REF v${VERSION}
        SHA512 059c5e39e5204e5ebcdd727c74b4001be44040df6804804fbba73455c36a7547fb2d07e035d8b694299b4d35fae29cc42305811f24160447810c6eaa2c6397ad
        HEAD_REF main
)

vcpkg_from_github(
        OUT_SOURCE_PATH REALM_CORE_SOURCE_PATH
        REPO realm/realm-core
        REF v14.4.1
        SHA512 a7f9098f258a021e15b30d897b8a2986988da0bf34bd3179eadcc1fcaa67532b47f0ebf97c43ecc562f4d77224e4e2ca5924ea3364b480aec4a9fafa9eb478dd
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH CATCH2_SOURCE_PATH
        REPO catchorg/Catch2
        REF v3.5.3
        SHA512 57c996f679cbad212cb0fde39e506bade37bd559c0e93e20f407f2a2f029e98b78661e10257f9c8e4cb5fd7d52d0ea1eae3d4a1f989c6d66fcb281e32e1688f6
        HEAD_REF master
)

file(COPY ${REALM_CORE_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/realm-core)
file(COPY ${CATCH2_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/realm-core/external/catch)

set(CPPREALM_CMAKE_OPTIONS -DREALM_CPP_NO_TESTS=ON -DREALM_CORE_SUBMODULE_BUILD=OFF)

if (ANDROID OR WIN32 OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND CPPREALM_CMAKE_OPTIONS -DREALM_USE_SYSTEM_OPENSSL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${CPPREALM_CMAKE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "cpprealm" CONFIG_PATH "cmake")
vcpkg_cmake_config_fixup(PACKAGE_NAME "Realm" CONFIG_PATH "share/cmake/Realm")

file(READ ${CURRENT_PACKAGES_DIR}/debug/include/cpprealm/internal/bridge/bridge_types.hpp DEBUG_TYPE_HEADER_CONTENTS)
set(REGEX_PATTERN "\\{([^()]*)\\}")
string(REGEX MATCHALL "${REGEX_PATTERN}" MATCHED_CONTENT "${DEBUG_TYPE_HEADER_CONTENTS}")
set(MATCHED_DEBUG_TYPE_HEADER_CONTENTS "${CMAKE_MATCH_1}")

file(READ ${CURRENT_PACKAGES_DIR}/include/cpprealm/internal/bridge/bridge_types.hpp RELEASE_TYPE_HEADER_CONTENTS)
set(REGEX_PATTERN "\\{([^()]*)\\}")
string(REGEX MATCHALL "${REGEX_PATTERN}" MATCHED_CONTENT "${RELEASE_TYPE_HEADER_CONTENTS}")
set(MATCHED_RELEASE_TYPE_HEADER_CONTENTS "${CMAKE_MATCH_1}")

string(REGEX REPLACE "\\{([^()]*)\\}" "
{
        #ifdef REALM_DEBUG
        ${MATCHED_DEBUG_TYPE_HEADER_CONTENTS}
        #else
        ${MATCHED_RELEASE_TYPE_HEADER_CONTENTS}
        #endif
}
    " MODIFIED_HEADER "${DEBUG_TYPE_HEADER_CONTENTS}")

file(WRITE ${CURRENT_PACKAGES_DIR}/include/cpprealm/internal/bridge/bridge_types.hpp "${MODIFIED_HEADER}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
