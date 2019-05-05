include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message("${PORT} currently requires the following tools from the system package manager:\n    python-yaml\n\nThis can be installed on Ubuntu systems via apt-get install python-yaml PYTHON2-yaml (depending on your current python default interpreter)")
endif() 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svaarala/duktape
    REF v2.0.3
    SHA512 6ad189f6f9291cbd7eb7227113302fd0c204018611bb37bf4acd7f6b0eb2a75837dac8fb9fba441a0d76e6f1dbad62e4750a6645f65de31611b089f6922bad26
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")
if(NOT EXISTS ${PYTHON2_DIR}/easy_install${EXECUTABLE_SUFFIX})
    if(NOT EXISTS ${PYTHON2_DIR}/Scripts/pip${EXECUTABLE_SUFFIX})
        vcpkg_download_distfile(GET_PIP
            URLS "https://bootstrap.pypa.io/get-pip.py"
            FILENAME "tools/python/python2/get-pip.py"
            SHA512 fdbcef1037dca7cc914e2304af657ebd08239cd18c3e79786dc25c8ea39957674e012d7ea8ae2c99006e4b61d3a5e24669ac5771dc186697fd9fdb40b6cc07ae
        )
        execute_process(COMMAND ${PYTHON2_DIR}/python${EXECUTABLE_SUFFIX} ${PYTHON2_DIR}/get-pip.py)
    endif()
    execute_process(COMMAND ${PYTHON2_DIR}/Scripts/pip${EXECUTABLE_SUFFIX} install pyyaml)
else()
    execute_process(COMMAND ${PYTHON2_DIR}/easy_install${EXECUTABLE_SUFFIX} pyyaml)
endif()

execute_process(COMMAND ${PYTHON2} ${SOURCE_PATH}/tools/configure.py --source-directory ${SOURCE_PATH}/src-input --output-directory ${SOURCE_PATH}/src --config-metadata ${SOURCE_PATH}/config -DDUK_USE_FASTINT)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        duk_config.h.patch 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

set(DUK_CONFIG_H_PATH "${CURRENT_PACKAGES_DIR}/include/duk_config.h")
file(READ ${DUK_CONFIG_H_PATH} CONTENT)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    string(REPLACE "// #undef DUK_F_DLL_BUILD" "#undef DUK_F_DLL_BUILD\n#define DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
else()
    string(REPLACE "// #undef DUK_F_DLL_BUILD" "#undef DUK_F_DLL_BUILD" CONTENT "${CONTENT}")
endif()
file(WRITE ${DUK_CONFIG_H_PATH} "${CONTENT}")

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/duktape" RENAME "copyright")

vcpkg_copy_pdbs()
