vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO realm/realm-cpp
        REF "ae469c149503570c4dd74b1b0e7be488b6996284"
        SHA512 "2ee7291b6dc7a5d6d101a794e5072bb0122f462fd597039089aabb387a8a6244eef055249c2db00fa4f2cfa7c6bb375ff22c50f761852bad5654554065329d2d"
        HEAD_REF "main")

set(CPPREALM_CMAKE_OPTIONS -DREALM_CPP_NO_TESTS=ON -DREALM_ENABLE_EXPERIMENTAL=ON -DREALMCXX_VERSION="2.1.0")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${CPPREALM_CMAKE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "cpprealm" CONFIG_PATH "cmake")

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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
