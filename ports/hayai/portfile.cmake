vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nickbruun/hayai
    REF 0234860c7a851362ab33efc6c018203cded3eb48
    SHA512 e4c65d834eddaeb77e73a3bc24645a531b93d26e32ff1daffbe71c579b76b4b8b4865f6c7ea07b378cafbe2da3a698414d4135f28fc9821eef995ed78d0987f2
    HEAD_REF master
)

if(VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINSTALL_HAYAI=ON
        -DBUILD_HAYAI_TESTS=OFF
        -DBUILD_HAYAI_SAMPLES=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/CMake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/CMake/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle manual-link libraries
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/hayai_main.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/hayai_main.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/hayai_main.lib
    )

    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/hayai-targets-debug.cmake
        "\${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/hayai_main.lib"
        "\${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/manual-link/hayai_main.lib"
    )
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/hayai_main.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/hayai_main.lib
        ${CURRENT_PACKAGES_DIR}/lib/manual-link/hayai_main.lib
    )

    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/hayai-targets-release.cmake
        "\${CMAKE_CURRENT_LIST_DIR}/../../lib/hayai_main.lib"
        "\${CMAKE_CURRENT_LIST_DIR}/../../lib/manual-link/hayai_main.lib"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
