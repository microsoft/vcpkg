include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikd/libsndfile
    REF cebfdf275e6173259bee6bfd40de22c8c102cf23
    SHA512  b981b9a5a457b73f444f4b134a76d9d7ab328369171a0043f89cfcf4567ca29a91ff75abfb362c4bc76c5fb0d25cb88cc397c37dd8f9d98b8892999c2e4e4123
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/uwp-createfile-getfilesize.patch"
        "${CMAKE_CURRENT_LIST_DIR}/uwp-createfile-getfilesize-addendum.patch"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" CRT_LIB_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

option(BUILD_EXECUTABLES "Build sndfile tools and install to folder tools" OFF)

if("external-libs" IN_LIST FEATURES)
    set(SNDFILE_WITH_EXTERNAL_LIBS ON)
else()
    set(SNDFILE_WITH_EXTERNAL_LIBS OFF)
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_EXE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_EXAMPLES=0 -DBUILD_REGTEST=0 -DBUILD_TESTING=0 -DENABLE_STATIC_RUNTIME=${CRT_LIB_STATIC} -DBUILD_STATIC_LIBS=${BUILD_STATIC} -DENABLE_EXTERNAL_LIBS=${SNDFILE_WITH_EXTERNAL_LIBS}
    OPTIONS_RELEASE -DBUILD_PROGRAMS=${BUILD_EXECUTABLES}
    # Setting ENABLE_PACKAGE_CONFIG=0 has no effect
    OPTIONS_DEBUG -DBUILD_PROGRAMS=0
)

vcpkg_install_cmake()

if(WIN32)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SndFile)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc/libsndfile ${CURRENT_PACKAGES_DIR}/share/${PORT}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

if(BUILD_EXECUTABLES)
    file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${TOOLS})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif(BUILD_EXECUTABLES)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
