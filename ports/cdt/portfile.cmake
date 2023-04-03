vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artem-ogre/CDT
    REF "${VERSION}"
    SHA512 811d1fede4960808954bc17f37c8639f52800c98562e9283517c666735ddf3b2f2f8a57992669899be13c40b0fc4439d3cd1a101cb596d2335ef4fc307408c63
    HEAD_REF master
    PATCHES
        boost-link.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "64-bit-index-type"     CDT_USE_64_BIT_INDEX_TYPE
        "as-compiled-library"   CDT_USE_AS_COMPILED_LIBRARY
        "boost"                 CDT_USE_BOOST
)

if (NOT CDT_USE_AS_COMPILED_LIBRARY)
    set(VCPKG_BUILD_TYPE "release") # header-only
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/CDT"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

if(CDT_USE_BOOST)
    set(CDT_USE_BOOST_STR "#if 1")
else()
    set(CDT_USE_BOOST_STR "#if 0")
endif()
foreach(FILE CDTUtils.h Triangulation.hpp)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${FILE}" "#ifdef CDT_USE_BOOST" "${CDT_USE_BOOST_STR}")
endforeach()

if (CDT_USE_AS_COMPILED_LIBRARY)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
