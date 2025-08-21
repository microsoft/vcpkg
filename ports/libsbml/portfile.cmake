vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sbmlteam/libsbml
    REF "v${VERSION}"
    SHA512 d4960b2ef12d00ae93ea883f945acf435a99763a0e2e751d94a15c7ff22fd41ff31cb16c1f37aa23257b3eb0de894201420962b008a6fe43ef0511fa2612846a
    HEAD_REF development
    PATCHES
        dependencies.diff
        dirent.diff
        no-docs.diff
        test-shared.diff
)
file(REMOVE
    "${SOURCE_PATH}/CMakeModules/FindBZ2.cmake"
    "${SOURCE_PATH}/CMakeModules/FindEXPAT.cmake"
    "${SOURCE_PATH}/CMakeModules/FindLIBXML.cmake"
    "${SOURCE_PATH}/CMakeModules/FindZLIB.cmake"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)

if("expat" IN_LIST FEATURES AND "libxml2" IN_LIST FEATURES)
    message(WARNING "Feature expat conflicts with feature libxml2. Selecting libxml2.")
    list(REMOVE_ITEM FEATURES "expat")
endif()

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
        expat       WITH_EXPAT
        libxml2     WITH_LIBXML
        zlib        WITH_ZLIB
        test        WITH_CHECK
        namespace   WITH_CPP_NAMESPACE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_L3V2EXTENDEDMATH:BOOL=ON
        -DWITH_STATIC_RUNTIME=${STATIC_RUNTIME}
        -DWITH_SWIG=OFF
    MAYBE_UNUSED_VARIABLES
        WITH_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

foreach(name IN ITEMS libsbml libsbml-static sbml sbml-static)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${name}-config.cmake")
        vcpkg_cmake_config_fixup(PACKAGE_NAME "${name}" CONFIG_PATH lib/cmake)
        if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake")
            configure_file("${CURRENT_PORT_DIR}/libsbml-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)
        endif()
        break()
    endif()
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sbml/common/extern.h" "defined LIBSBML_STATIC" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sbml/xml/XMLExtern.h" "defined(LIBLAX_STATIC)" "1")
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsbml.pc" " -lsbml" " -lsbml-static")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsbml.pc" " -lsbml" " -lsbml-static")
        endif()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
