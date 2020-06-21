set(_RELEASE_ONLY_PATCHES)
if(NOT VCPKG_USE_HEAD_VERSION)
    vcpkg_download_distfile(
        _RELEASE_ONLY_PATCHES
        URLS "https://github.com/mosra/magnum-plugins/commit/c2a05465fa43befbb628b424378e328fa42923b7.diff"
        FILENAME "c2a05465fa43befbb628b424378e328fa42923b7.diff"
        SHA512 e03953ff7319b3b8e3644b8e25c006a856dd6a85cec6e4c033f9b2059af7ae39ed84b76c11c93c41ea6a681d7f34dd5980806f49f760d1c26778047c90cc76df
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-plugins
    REF v2019.10
    SHA512 702c43b0d323dc5b903ffee3dd9aaecf2de3b6bb00e7b243880e433df12efe337e512aac75a6f38adce02eb94f3065770ff6a03b7241198f27b5c46de63e5750
    HEAD_REF master
    PATCHES
        001-tools-path.patch
        ${_RELEASE_ONLY_PATCHES}
)

if(basisimporter IN_LIST FEATURES OR basisimageconverter IN_LIST FEATURES)
    # Bundle Basis Universal, a commit that's before the UASTC support (which
    # is not implemented yet). The repo has big unrequired files in its
    # history, so we're downloading just a snapshot instead of a git clone.
    vcpkg_download_distfile(
        _BASIS_UNIVERSAL_PATCHES
        URLS "https://github.com/BinomialLLC/basis_universal/commit/e9c55faac7745ebf38d08cd3b4f71aaf542f8191.diff"
        FILENAME "e9c55faac7745ebf38d08cd3b4f71aaf542f8191.patch"
        SHA512 e5dda11de2ba8cfd39728e69c74a7656bb522e509786fe5673c94b26be9bd4bee897510096479ee6323f5276d34cba1c44c60804a515c0b35ff7b6ac9d625b88
    )
    set(_BASIS_VERSION "8565af680d1bd2ad56ab227ca7d96c56dfbe93ed")
    vcpkg_download_distfile(
        _BASIS_UNIVERSAL_ARCHIVE
        URLS "https://github.com/BinomialLLC/basis_universal/archive/${_BASIS_VERSION}.tar.gz"
        FILENAME "basis-universal-${_BASIS_VERSION}.tar.gz"
        SHA512 65062ab3ba675c46760f56475a7528189ed4097fb9bab8316e25d9e23ffec2a9560eb9a6897468baf2a6ab2bd698b5907283e96deaeaef178085a47f9d371bb2
    )
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH _BASIS_UNIVERSAL_SOURCE
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

# Handle features
set(_COMPONENT_FLAGS "")
foreach(_feature IN LISTS ALL_FEATURES)
    # Uppercase the feature name and replace "-" with "_"
    string(TOUPPER "${_feature}" _FEATURE)
    string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

    # Turn "-DWITH_*=" ON or OFF depending on whether the feature
    # is in the list.
    if(_feature IN_LIST FEATURES)
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=ON")
    else()
        list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=OFF")
    endif()
endforeach()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        ${_COMPONENT_FLAGS}
        -DBUILD_STATIC=${BUILD_PLUGINS_STATIC}
        -DBUILD_PLUGINS_STATIC=${BUILD_PLUGINS_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_install_cmake()

# Debug includes and share are the same as release
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share)

# Clean up empty directories, if not building anything.
# FEATURES may only contain "core", but that does not build anything.
if(NOT FEATURES OR FEATURES STREQUAL "core")
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/debug)
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    # move plugin libs to conventional place
    file(GLOB_RECURSE LIB_TO_MOVE ${CURRENT_PACKAGES_DIR}/lib/magnum/*)
    file(COPY ${LIB_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/magnum)
    file(GLOB_RECURSE LIB_TO_MOVE_DBG ${CURRENT_PACKAGES_DIR}/debug/lib/magnum/*)
    file(COPY ${LIB_TO_MOVE_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/magnum)
else()
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/magnum)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/magnum-d)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/magnum-plugins)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/COPYING ${CURRENT_PACKAGES_DIR}/share/magnum-plugins/copyright)

vcpkg_copy_pdbs()
