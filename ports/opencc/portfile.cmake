include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BYVoid/OpenCC
    REF 192c50f30f6cf3abf0512f1ae84f4d7c0cbb3e51
    SHA512 4b4bb61ad0bb75d113a18830b83c91d852ba782186100ce244152fa42f03a7cde69b9189aaf69e7b3ae33c52b50a449d3055bb465651fc730138ec5283d6f3b5
    HEAD_REF master
    PATCHES
        fix-dll-install-path.patch
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

vcpkg_install_cmake()

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
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    foreach(opencc_tool opencc opencc_dict opencc_phrase_extract)
        file(REMOVE
            ${CURRENT_PACKAGES_DIR}/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/${opencc_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        )
    endforeach()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
