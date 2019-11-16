include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message("${PORT} currently requires the following tools from the system package manager:\n    python-yaml\n\nThis can be installed on Ubuntu systems via apt-get install python-yaml PYTHON2-yaml (depending on your current python default interpreter)")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svaarala/duktape
    REF v2.4.0
    SHA512 5f42ff6faab8d49531423e199c032fd2de49524bab71f39d1cf822e6f9ee82a6089c9a93837ae7849d19a95693318a8480986e4672f6f73f3182b4902e6b2daa
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/duktapeConfig.cmake.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

if(VCPKG_TARGET_IS_WINDOWS)
    set(EXECUTABLE_SUFFIX ".exe")
    set(PYTHON_OPTION "")
else()
    set(EXECUTABLE_SUFFIX "")
    set(PYTHON_OPTION "--user")
endif()

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")
if(NOT EXISTS ${PYTHON2_DIR}/easy_install${EXECUTABLE_SUFFIX})
    if(NOT EXISTS ${PYTHON2_DIR}/Scripts/pip${EXECUTABLE_SUFFIX})
        vcpkg_from_github(
            OUT_SOURCE_PATH PYFILE_PATH
            REPO pypa/get-pip
            REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
            SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
            HEAD_REF master
        )
        execute_process(COMMAND ${PYTHON2_DIR}/python${EXECUTABLE_SUFFIX} ${PYFILE_PATH}/get-pip.py ${PYTHON_OPTION})
    endif()
    execute_process(COMMAND ${PYTHON2_DIR}/Scripts/pip${EXECUTABLE_SUFFIX} install pyyaml ${PYTHON_OPTION})
else()
    execute_process(COMMAND ${PYTHON2_DIR}/easy_install${EXECUTABLE_SUFFIX} pyyaml)
endif()

execute_process(COMMAND ${PYTHON2} ${SOURCE_PATH}/tools/configure.py --source-directory ${SOURCE_PATH}/src-input --output-directory ${SOURCE_PATH}/src --config-metadata ${SOURCE_PATH}/config -DDUK_USE_FASTINT)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(DUK_CONFIG_H_PATH "${SOURCE_PATH}/src/duk_config.h")
  file(READ ${DUK_CONFIG_H_PATH} CONTENT)
  string(REPLACE "#undef DUK_F_DLL_BUILD" "#define DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
  file(WRITE ${DUK_CONFIG_H_PATH} "${CONTENT}")
else()
  set(DUK_CONFIG_H_PATH "${SOURCE_PATH}/src/duk_config.h")
  file(READ ${DUK_CONFIG_H_PATH} CONTENT)
  string(REPLACE "#define DUK_F_DLL_BUILD" "#undef DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
  file(WRITE ${DUK_CONFIG_H_PATH} "${CONTENT}")
endif()

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
