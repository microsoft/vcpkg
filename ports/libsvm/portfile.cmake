include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cjlin1/libsvm
    REF v323
    SHA512 c4abd408acf860c76cfc743e6c65d241fcb18443e741fc0f557f7cf7b4d0913c05f3afc5d49de8a42ff88db6fc7b046d08bcb0a3d2a24ba23e297ed1cfbb9131
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools SVM_BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSVM_BUILD_TOOLS=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

# Install tools
if ("tools" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(EXECUTABLE_SUFFIX ".exe")
    else()
        set(EXECUTABLE_SUFFIX "")
    endif()

    foreach (libsvm_tool svm-predict svm-scale svm-toy svm-train)
        if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/${libsvm_tool}${EXECUTABLE_SUFFIX})
            file(
                COPY ${CURRENT_PACKAGES_DIR}/bin/${libsvm_tool}${EXECUTABLE_SUFFIX}
                DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
            )
            file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${libsvm_tool}${EXECUTABLE_SUFFIX})
        endif ()

        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
    endforeach ()

    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    endif ()
endif ()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYRIGHT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME unofficial-${PORT})
