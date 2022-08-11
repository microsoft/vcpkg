vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF 2ddaffd31f6f9cae776ec2faa4b88d5c45e0d4d6 #1.1.4
    SHA512 96a20242bbaad76c24b15422339e38db6eb786b28a0397939ca11471fe484bbc65aedbf7313a6b381fde61d6ec69e0d13b6d899565a8c4af8c5198e4f5656d56
    HEAD_REF master
    PATCHES 
        fix-dependencies.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        rapidjson       USE_SYSTEM_RAPIDJSON
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DBUILD_DOCUMENTATION=OFF
        -DENABLE_GTEST=OFF
)

vcpkg_cmake_install(
    DISABLE_PARALLEL
)

vcpkg_copy_pdbs()

if(tools IN_LIST FEATURES)
    foreach(opencc_tool opencc opencc_dict opencc_phrase_extract)
        file(COPY
            "${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        )
    endforeach()

    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    foreach(opencc_tool opencc opencc_dict opencc_phrase_extract)
        file(REMOVE
            "${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${CURRENT_PACKAGES_DIR}/debug/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        )
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_fixup_pkgconfig()
