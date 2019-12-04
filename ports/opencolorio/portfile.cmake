include(vcpkg_common_definitions)
include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_BUILD_SHARED OFF)
    set(_BUILD_STATIC ON)
else()
    set(_BUILD_SHARED ON)
    set(_BUILD_STATIC OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imageworks/OpenColorIO
    REF v1.1.1
    SHA512 bed722f9ddce1887d28aacef2882debccd7c3f3c0c708d2723fea58a097de9f02721af9e85453e089ffda5406aef593ab6536c6886307823c132aa787e492e33
    HEAD_REF master
    PATCHES
        0001-lcms-dependency-search.patch
        0002-msvc-cpluscplus.patch
        0003-osx-self-assign-field.patch
        0004-yaml-dependency-search.patch
        0005-tinyxml-dependency-search.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        applications OCIO_BUILD_APPS
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_PATH ${PYTHON2} DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON2_PATH})

# TODO(theblackunknown) build additional targets based on feature

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOCIO_BUILD_SHARED:BOOL=${_BUILD_SHARED}
        -DOCIO_BUILD_STATIC:BOOL=${_BUILD_STATIC}
        -DOCIO_BUILD_TRUELIGHT:BOOL=OFF
        -DOCIO_BUILD_NUKE:BOOL=OFF
        -DOCIO_BUILD_DOCS:BOOL=OFF
        -DOCIO_BUILD_TESTS:BOOL=OFF
        -DOCIO_BUILD_PYGLUE:BOOL=OFF
        -DOCIO_BUILD_JNIGLUE:BOOL=OFF
        -DOCIO_STATIC_JNIGLUE:BOOL=OFF
        -DUSE_EXTERNAL_TINYXML:BOOL=ON
        -DUSE_EXTERNAL_YAML:BOOL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

vcpkg_copy_pdbs()

if("applications" IN_LIST FEATURES)
    # port applications to tools
    file(MAKE_DIRECTORY
        "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )

    file(GLOB_RECURSE _TOOLS
        "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
    foreach(_TOOL IN LISTS _TOOLS)
        get_filename_component(_NAME ${_TOOL} NAME)
        file(RENAME "${_TOOL}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_NAME}")
    endforeach()

    file(GLOB_RECURSE _TOOLS
        "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
    foreach(_TOOL IN LISTS _TOOLS)
        get_filename_component(_NAME ${_TOOL} NAME)
        file(RENAME "${_TOOL}" "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/${_NAME}")
    endforeach()

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
endif()

# Clean redundant files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# CMake Configs leftovers
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/OpenColorIOConfig.cmake
    ${CURRENT_PACKAGES_DIR}/debug/OpenColorIOConfig.cmake
)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
