include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    message("The current range-v3 releases are not compatible with the current MSVC releases.")
    message("The latest available range-v3 fork compatible with MSVC will be used instead.")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ericniebler/range-v3
        REF 0.3.5
        SHA512 0b8b97c32760f19e7a3f35b0f28b0c15c7735fbd1aa54f685c58faf50bf2cf112aed4ac7cfa9154b9caf7047400a6c7fd5c33d978f2e3cec6bc392a758aeabad
        HEAD_REF master
    )

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DRANGE_V3_NO_TESTING=ON
            -DRANGE_V3_NO_EXAMPLE=ON
            -DRANGE_V3_NO_PERF=ON
            -DRANGE_V3_NO_HEADER_CHECK=ON
    )

    vcpkg_install_cmake()

    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/range-v3)

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

    vcpkg_copy_pdbs()

    file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/range-v3)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/range-v3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/range-v3/copyright)
endif()
