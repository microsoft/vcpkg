vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF e8ec6d59f264a4a42e310148a9534a8cc0123928
    SHA512 e6b3f6d681223b299795c324a48e82609abd1f411d3cbd5f9d8607284ec04717fa9878953d037c25a931a0857f50a5c0e883e0d44ddbea18c50830ad49514c59
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_DOCUMENTATION=OFF
        -DENABLE_GTEST=OFF
)

vcpkg_install_cmake(
    DISABLE_PARALLEL
)

vcpkg_copy_pdbs()

if(tools IN_LIST FEATURES)
    foreach(opencc_tool opencc opencc_dict opencc_phrase_extract)
        file(COPY
            ${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
        )
    endforeach()

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    foreach(opencc_tool opencc opencc_dict opencc_phrase_extract)
        file(REMOVE
            ${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        )
    endforeach()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_fixup_pkgconfig()
