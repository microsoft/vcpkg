include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sbml/files/libsbml/5.18.0/stable/libSBML-5.18.0-core-plus-packages-src.tar.gz/download"
    FILENAME "libSBML-5.18.0.zip"
    SHA512 49dedaa2fcd2077e7389a8f940adf931d80aa7a8f9d57330328372d2ac8ebcaeb03a20524df2fe0f1c6933587904613754585076c46e6cb5d6f7a001f427185b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES fix-linkage-type.patch
)

SET(STATIC_RUNTIME OFF)
if (VCPKG_CRT_LINKAGE AND ${VCPKG_CRT_LINKAGE} MATCHES "static")
    SET(STATIC_RUNTIME ON)
endif()

SET(STATIC_LIBRARY OFF)
if (VCPKG_LIBRARY_LINKAGE AND ${VCPKG_LIBRARY_LINKAGE} MATCHES "static")
    SET(STATIC_LIBRARY ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
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
    check       WITH_CHECK
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

set(WITH_CPP_NAMESPACE OFF)
if ("namespace" IN_LIST FEATURES)
    set(WITH_CPP_NAMESPACE ON)
endif()

if (WITH_EXPAT AND WITH_LIBXML)
    message("Feature expat conflict with feature libxml2, currently using libxml2...")
    set(WITH_EXPAT OFF)
endif()

if ("check" IN_LIST FEATURES AND WIN32)
    message(FATAL_ERROR "Feature check only support UNIX.")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS ${FEATURE_OPTIONS}
            -DWITH_EXPAT=${WITH_EXPAT}
            -DWITH_LIBXML=${WITH_LIBXML}
            -DENABLE_L3V2EXTENDEDMATH:BOOL=ON
            -DWITH_CPP_NAMESPACE:BOOL=${WITH_CPP_NAMESPACE}
            -DWITH_STATIC_RUNTIME=${STATIC_RUNTIME}
            -DLIBSBML_SKIP_SHARED_LIBRARY=${STATIC_LIBRARY}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB TXT_FILES ${CURRENT_PACKAGES_DIR}/debug/*.txt)
if (TXT_FILES)
    file(REMOVE ${TXT_FILES})
endif()
file(GLOB TXT_FILES ${CURRENT_PACKAGES_DIR}/*.txt)
if (TXT_FILES)
    file(REMOVE ${TXT_FILES})
endif()

if (EXISTS ${CURRENT_PACKAGES_DIR}/debug/share)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)