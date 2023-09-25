vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-plugins
    REF v2020.06
    SHA512 3c11c2928bfc9d04c1ad64f72b6ffac6cf80a1ef3aacc5d0486b9ad955cf4f6ea6d5dcb3846dc5d73f64ec522a015eafb997f62c79ad7ff91169702341f23af0
    HEAD_REF master
    PATCHES
        002-fix-stb-conflict.patch
)

if("basisimporter" IN_LIST FEATURES OR "basisimageconverter" IN_LIST FEATURES)
    # Bundle Basis Universal. The repo has big unrequired files in its
    # history, so we're downloading just a snapshot instead of a git clone.
    if(VCPKG_USE_HEAD_VERSION)
        # v1_15_update2
        set(_BASIS_VERSION "v1_15_update2")
        set(_BASIS_SHA512 "a898a057b57ac64f6c0bf5fce0b599e23421ccdd015ea7bb668bce8b9292ef55b098f3d05854a2fb5363959932b75cd0a842664ae7d4f71f3537dc11301c1b32")
    else()
        # A commit that's before the UASTC support (which is not implemented yet)
        vcpkg_download_distfile(
            _BASIS_UNIVERSAL_PATCHES
            URLS "https://github.com/BinomialLLC/basis_universal/commit/e9c55faac7745ebf38d08cd3b4f71aaf542f8191.diff?full_index=1"
            FILENAME "e9c55faac7745ebf38d08cd3b4f71aaf542f8191.patch"
            SHA512 1121d5fa6cce617cfc393b48ac13f21e7f977522746702b3968f5fc86c58de6a3b91e4371692e8566747a975cb46de5421ab1cf635d3904fd74c07bbdfcaa78e
        )
        set(_BASIS_VERSION "8565af680d1bd2ad56ab227ca7d96c56dfbe93ed")
        set(_BASIS_SHA512 "65062ab3ba675c46760f56475a7528189ed4097fb9bab8316e25d9e23ffec2a9560eb9a6897468baf2a6ab2bd698b5907283e96deaeaef178085a47f9d371bb2")
    endif()
    vcpkg_download_distfile(
        _BASIS_UNIVERSAL_ARCHIVE
        URLS "https://github.com/BinomialLLC/basis_universal/archive/${_BASIS_VERSION}.tar.gz"
        FILENAME "basis-universal-${_BASIS_VERSION}.tar.gz"
        SHA512 ${_BASIS_SHA512}
    )
    vcpkg_extract_source_archive(
        _BASIS_UNIVERSAL_SOURCE
        ARCHIVE ${_BASIS_UNIVERSAL_ARCHIVE}
        WORKING_DIRECTORY "${SOURCE_PATH}/src/external"
        PATCHES
            ${_BASIS_UNIVERSAL_PATCHES})
    # Remove potentially cached directory which would cause renaming to fail
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/external/basis-universal")
    # Rename the output folder so that magnum auto-detects it
    file(RENAME ${_BASIS_UNIVERSAL_SOURCE} "${SOURCE_PATH}/src/external/basis-universal")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_PLUGINS_STATIC 1)
else()
    set(BUILD_PLUGINS_STATIC 0)
endif()

# Head only features
set(ALL_SUPPORTED_FEATURES ${ALL_FEATURES})
if(NOT VCPKG_USE_HEAD_VERSION)
    list(REMOVE_ITEM ALL_SUPPORTED_FEATURES cgltfimporter glslangshaderconverter
        ktximageconverter ktximporter openexrimageconverter openexrimporter
        spirvtoolsshaderconverter stbdxtimageconverter)
    message(WARNING "Features cgltfimporter, glslangshaderconverter, ktximageconverter, ktximporter, openexrimageconverter, openexrimporter, spirvtoolsshaderconverter and stbdxtimageconverter are not available when building non-head version.")
endif()

set(_COMPONENTS "")
# Generate cmake parameters from feature names
foreach(_feature IN LISTS ALL_SUPPORTED_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Final feature is empty, ignore it
    if(_feature)
        list(APPEND _COMPONENTS ${_feature} WITH_${_FEATURE})
    endif()
endforeach()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES ${_COMPONENTS})

if(VCPKG_CROSSCOMPILING)
    set(CORRADE_RC_EXECUTABLE "-DCORRADE_RC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/corrade/corrade-rc${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${CORRADE_RC_EXECUTABLE}
        -DBUILD_STATIC=${BUILD_PLUGINS_STATIC}
        -DBUILD_PLUGINS_STATIC=${BUILD_PLUGINS_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MagnumPlugins CONFIG_PATH share/cmake/MagnumPlugins)

# Debug includes and share are the same as release
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share")

# Clean up empty directories, if not building anything.
# FEATURES may only contain "core", but that does not build anything.
if(NOT FEATURES OR FEATURES STREQUAL "core")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/debug")
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    # move plugin libs to conventional place
    file(GLOB_RECURSE LIB_TO_MOVE "${CURRENT_PACKAGES_DIR}/lib/magnum/*")
    file(COPY ${LIB_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/magnum")
    file(GLOB_RECURSE LIB_TO_MOVE_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/magnum/*")
    file(COPY ${LIB_TO_MOVE_DBG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/magnum")
else()
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
    # On windows, plugins are "Modules" that cannot be linked as shared
    # libraries, but are meant to be loaded at runtime.
    # While this is handled adequately through the CMake project, the auto-magic
    # linking with visual studio might try to link the import libs anyway.
    #
    # We delete the import libraries here to avoid the auto-magic linking
    # for plugins which are loaded at runtime.
    if(WIN32)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/magnum")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/magnum-d")
    endif()
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_copy_pdbs()
