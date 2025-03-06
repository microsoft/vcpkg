include(vcpkg_common_functions)

# Debug Tips, pass to vcpkg: --debug --x-cmake-args=-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

# Set the package name and version
set(PACKAGE_NAME node)
set(VERSION v21.7.1)

vcpkg_find_acquire_program(NASM)
get_filename_component(NASM_DIR "${NASM}" DIRECTORY)
vcpkg_add_to_path(${NASM_DIR})

vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_DIR "${NINJA}" DIRECTORY)
vcpkg_add_to_path(${NINJA_DIR})

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_find_acquire_program(MAKE)
get_filename_component(MAKE_DIR "${MAKE}" DIRECTORY)
vcpkg_add_to_path(${MAKE_DIR})

# Download the source code
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nodejs/node/archive/refs/tags/${VERSION}.tar.gz"
    FILENAME "${PACKAGE_NAME}-${VERSION}.tar.gz"
    SHA512 "8d8c4d006c72315da80a52d15ea59c9cda3109bd58b086c3c5a153fa8af098c221cc3f3eb5bef287ad233195ab0ff728dfbbe14f0fed0f3c286479d63d29aab5"
)

# Extract the source code
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

set(TEMP_DIR_TO_INSTALL ${SOURCE_PATH}/opt)

if(VCPKG_TARGET_IS_WINDOWS)
    #TBD
    vcpkg_execute_required_process(
        COMMAND vcbuild.bat x64 dll nobuild
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}
    )
else()
    vcpkg_execute_required_process(
        COMMAND python3 configure.py --ninja --shared --debug --prefix=${TEMP_INSTALLED_TO_DIR}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}
    )
endif()
if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
    message(FATAL_ERROR "configure failed")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    #TBD
    vcpkg_execute_required_process(
        #COMMAND msbuild node.sln /m:2 /t:node /p:Configuration=Debug /p:Platform=x64 /clp:NoItemAndPropertyList;Verbosity=minimal /nologo /p:UseMultiToolTask=True /p:EnforceProcessCountAcrossBuilds=True /p:MultiProcMaxCount=%NUMBER_OF_PROCESSORS% /p:CLToolPath=c:\ccache\ /p:TrackFileAccess=false /p:ForceImportAfterCppProps=${CMAKE_CURRENT_SOURCE_DIR}/props_4_ccache.props            
        COMMAND msbuild node.sln /t:node /p:Configuration=Debug /p:Platform=x64 /clp:NoItemAndPropertyList;Verbosity=minimal /nologo
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
        message(FATAL_ERROR "debug build failed")
    endif()
    #TBD
    vcpkg_execute_required_process(
        #COMMAND msbuild node.sln /m:2 /t:node /p:Configuration=Release /p:Platform=x64 /clp:NoItemAndPropertyList;Verbosity=minimal /nologo /p:UseMultiToolTask=True /p:EnforceProcessCountAcrossBuilds=True /p:MultiProcMaxCount=%NUMBER_OF_PROCESSORS% /p:CLToolPath=c:\ccache\ /p:TrackFileAccess=false /p:ForceImportAfterCppProps=${CMAKE_CURRENT_SOURCE_DIR}/props_4_ccache.props            
        COMMAND msbuild node.sln /t:node /p:Configuration=Release /p:Platform=x64 /clp:NoItemAndPropertyList;Verbosity=minimal /nologo
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
    message(FATAL_ERROR "release build failed")
else()
    vcpkg_execute_required_process(
        COMMAND make -j ${VCPKG_NUM_PROCESSES}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
        message(FATAL_ERROR "build failed")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_execute_required_process(
        COMMAND python3 tools/install.py install --dest-dir ${TEMP_DIR_TO_INSTALL} --prefix \  --build-dir out/Release/ --headers-only
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-release-${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
        message(FATAL_ERROR "header install failed")
    endif()

    file(COPY ${SOURCE_PATH}/out/Debug/libnode.lib DESTINATION ${TEMP_DIR_TO_INSTALL}/debug/lib)
    file(COPY ${SOURCE_PATH}/out/Release/libnode.lib DESTINATION ${TEMP_DIR_TO_INSTALL}/lib)
else()
    vcpkg_execute_required_process(
        COMMAND python3 tools/install.py install --dest-dir '' --prefix ${TEMP_DIR_TO_INSTALL}  --build-dir out/Release/
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-release-${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
        message(FATAL_ERROR "release install failed")
    endif()

    vcpkg_execute_required_process(
        COMMAND python3 tools/install.py install --dest-dir '' --prefix ${TEMP_DIR_TO_INSTALL}  --build-dir out/Debug/
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME install-debug--${TARGET_TRIPLET}
    )
    if(NOT ${VCPKG_EXECUTE_REQUIRED_PROCESS_RESULT} EQUAL 0)
        message(FATAL_ERROR "debug install failed")
    endif()
endif()

message("--begin-- copy files from ${SOURCE_PATH}/${TEMP_DIR_TO_INSTALL} to ${CURRENT_PACKAGES_DIR}")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(INSTALL ${TEMP_DIR_TO_INSTALL}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${TEMP_DIR_TO_INSTALL}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${TEMP_DIR_TO_INSTALL}/debug/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL ${TEMP_DIR_TO_INSTALL}/bin DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${TEMP_DIR_TO_INSTALL}/debug/bin DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/example DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
message("--end-- copy files from ${SOURCE_PATH}/${TEMP_DIR_TO_INSTALL} to ${CURRENT_PACKAGES_DIR}")

# TBD
# file(REMOVE_RECURSE ${TEMP_DIR_TO_INSTALL})
