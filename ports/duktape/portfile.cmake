if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools from the system package manager:\n    python-yaml\n\nThis can be installed on Ubuntu systems via apt-get install python-yaml PYTHON2-yaml (depending on your current python default interpreter)")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svaarala/duktape
    REF 6001888049cb42656f8649db020e804bcdeca6a7 # v2.5.0
    SHA512 ffbc7f1b16b7469ddfc0af0054a7891ffda128cc099e693773c6b4597ee6a96f8a08d354f7a7cf3a1f16369bef7b7a94c2670a617ec0355cc3614f56e1668dc4
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/duktapeConfig.cmake.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

if (VCPKG_TARGET_IS_WINDOWS)
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

vcpkg_execute_required_process(
    COMMAND ${PYTHON2} tools/configure.py --source-directory src-input --output-directory src --config-metadata config -DDUK_USE_FASTINT
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME pre-configure
)

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
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
