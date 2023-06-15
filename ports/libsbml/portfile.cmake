vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sbmlteam/libsbml
    REF "v${VERSION}"
    SHA512 c40f164ebd05a36f140ce2684dedb4bbccc51a2732383d3935fca1258738a9b9ba5bc1be2061f3b113b213e5cbb7fe22e9dca43ff78d91964c79cad093e55466
    HEAD_REF development
    PATCHES
        fix-deps-libxml.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DYNAMIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        comp        ENABLE_COMP
        fbc         ENABLE_FBC
        groups      ENABLE_GROUPS
        layout      ENABLE_LAYOUT
        multi       ENABLE_MULTI
        qual        ENABLE_QUAL
        render      ENABLE_RENDER
        bzip2       WITH_BZIP2
        zlib        WITH_ZLIB
        test        WITH_CHECK
        namespace   WITH_CPP_NAMESPACE
)

# Handle conflict features
set(WITH_EXPAT OFF)
if ("expat" IN_LIST FEATURES)
    set(WITH_EXPAT ON)
endif()

set(WITH_LIBXML OFF)
if ("libxml2" IN_LIST FEATURES)
    set(WITH_LIBXML ON)
endif()

if (WITH_EXPAT AND WITH_LIBXML)
    message("Feature expat conflict with feature libxml2, currently using libxml2...")
    set(WITH_EXPAT OFF)
endif()

if ("test" IN_LIST FEATURES AND WIN32)
    message(FATAL_ERROR "Feature test only support UNIX.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DWITH_EXPAT=${WITH_EXPAT}
        -DWITH_LIBXML=${WITH_LIBXML}
        -DENABLE_L3V2EXTENDEDMATH:BOOL=ON
        -DWITH_STATIC_RUNTIME=${STATIC_RUNTIME}
        -DLIBSBML_SKIP_SHARED_LIBRARY=${STATIC_LIBRARY}
        -DLIBSBML_SKIP_STATIC_LIBRARY=${DYNAMIC_LIBRARY}
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME libsbml-static CONFIG_PATH lib/cmake)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/libsbml-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(GLOB TXT_FILES "${CURRENT_PACKAGES_DIR}/debug/*.txt")
if (TXT_FILES)
    file(REMOVE ${TXT_FILES})
endif()
file(GLOB TXT_FILES "${CURRENT_PACKAGES_DIR}/*.txt")
if (TXT_FILES)
    file(REMOVE ${TXT_FILES})
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/README.md")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/README.md")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
vcpkg_fixup_pkgconfig()
