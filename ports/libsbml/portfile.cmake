vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sbmlteam/libsbml
    REF 118ffbf11f1a5245cc544c1eac71019d979ecb20 #libSBML-5.19.0
    SHA512 7fe8b4d594876c6408e01c646187cb1587d0b4e12707a43286150d4e4646841e547bde971de917de1cdfbbb9365172aeac43c8e02f7d354400f9166f0f1c2c3d
    HEAD_REF development
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        comp        ENABLE_COMP
        fbc         ENABLE_FBC
        groups      ENABLE_GROUPS
        layout      ENABLE_LAYOUT
        multi       ENABLE_MULTI
        qual        ENABLE_QUAL
        render      ENABLE_RENDER
        render      ENABLE_LAYOUT
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

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

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)