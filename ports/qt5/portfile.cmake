include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qt-5.7.1)
set(OUTPUT_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
set(ENV{QTDIR} ${OUTPUT_PATH}/qtbase)
set(ENV{PATH} "${OUTPUT_PATH}/qtbase/bin;$ENV{PATH}")

find_program(NMAKE nmake)
vcpkg_find_acquire_program(JOM)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
get_filename_component(JOM_EXE_PATH ${JOM} DIRECTORY)
set(ENV{PATH} "${JOM_EXE_PATH};${PYTHON3_EXE_PATH};${CURRENT_INSTALLED_DIR}/bin;$ENV{PATH};${PERL_EXE_PATH}")
set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://download.qt.io/official_releases/qt/5.7/5.7.1/single/qt-everywhere-opensource-src-5.7.1.7z"
    FILENAME "qt-5.7.1.7z"
    SHA512 3ffcf490a1c0107a05113aebbf70015c50d05fbb35439273c243133ddb146d51aacae15ecd6411d563cc8cfe103df896394c365a69bc48fc86c3bce6a1af3107
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})
if (EXISTS ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.7.1)
    file(RENAME ${CURRENT_BUILDTREES_DIR}/src/qt-everywhere-opensource-src-5.7.1 ${CURRENT_BUILDTREES_DIR}/src/qt-5.7.1)
endif()

if(EXISTS ${OUTPUT_PATH})
    file(REMOVE_RECURSE ${OUTPUT_PATH})
    if(EXISTS ${OUTPUT_PATH})
        message(FATAL_ERROR "Could not clean output directory.")
    endif()
endif()
file(MAKE_DIRECTORY ${OUTPUT_PATH})
if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
    list(APPEND QT_RUNTIME_LINKAGE "-static")
    list(APPEND QT_RUNTIME_LINKAGE "-static-runtime")
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/set-static-qmakespec.patch"
        QUIET
    )
else()
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/set-shared-qmakespec.patch"
        QUIET
    )
endif()

message(STATUS "Configuring ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND "${SOURCE_PATH}/configure.bat"
        -confirm-license -opensource -platform win32-msvc2015
        -debug-and-release -force-debug-info ${QT_RUNTIME_LINKAGE}
        -qt-zlib
        -no-libjpeg
        -no-libpng
        -no-freetype
        -qt-pcre
        -no-harfbuzz
        -no-angle
        -no-inotify
        -no-mtdev
        -no-evdev
        -system-doubleconversion
        -no-iconv
        -system-sqlite
        -opengl desktop # other options are "-no-opengl" and "-opengl angle"
        -mp
        -nomake examples -nomake tests -no-compile-examples
        -skip webengine -skip declarative
        -qt-sql-sqlite -qt-sql-psql
        -prefix ${CURRENT_PACKAGES_DIR}
        -bindir ${CURRENT_PACKAGES_DIR}/bin
        -hostbindir ${CURRENT_PACKAGES_DIR}/tools/qt5
        -archdatadir ${CURRENT_PACKAGES_DIR}/share/qt5
        -datadir ${CURRENT_PACKAGES_DIR}/share/qt5
        -plugindir ${CURRENT_PACKAGES_DIR}/plugins
    WORKING_DIRECTORY ${OUTPUT_PATH}
    LOGNAME configure-${TARGET_TRIPLET}
)
message(STATUS "Configure ${TARGET_TRIPLET} done")

message(STATUS "Building ${TARGET_TRIPLET}")
# Multiple executions are required due to https://bugreports.qt.io/browse/QTBUG-53393
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(COUNT 1)
else()
    set(COUNT 3)
endif()
vcpkg_execute_required_process_repeat(
    COUNT ${COUNT}
    COMMAND ${JOM}
    WORKING_DIRECTORY ${OUTPUT_PATH}
    LOGNAME build-${TARGET_TRIPLET}
)
message(STATUS "Build ${TARGET_TRIPLET} done")

message(STATUS "Installing ${TARGET_TRIPLET}")
vcpkg_execute_required_process(
    COMMAND ${JOM} -j1 install
    WORKING_DIRECTORY ${OUTPUT_PATH}
    LOGNAME install-${TARGET_TRIPLET}
)
message(STATUS "Install ${TARGET_TRIPLET} done")

message(STATUS "Packaging ${TARGET_TRIPLET}")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/cmake)

if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL dynamic)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug
        FILES_MATCHING PATTERN "*d.dll"
    )
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug
        FILES_MATCHING PATTERN "*d.pdb"
    )
    file(GLOB DEBUG_BIN_FILES "${CURRENT_PACKAGES_DIR}/bin/*d.dll")
    file(REMOVE ${DEBUG_BIN_FILES})
    file(GLOB DEBUG_BIN_FILES "${CURRENT_PACKAGES_DIR}/bin/*d.pdb")
    file(REMOVE ${DEBUG_BIN_FILES})
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin/Qt5Gamepad.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/Qt5Gamepad.dll ${CURRENT_PACKAGES_DIR}/bin/Qt5Gamepad.dll)
    endif()
endif()

file(INSTALL ${CURRENT_PACKAGES_DIR}/lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug
    FILES_MATCHING PATTERN "*d.lib"
)
file(INSTALL ${CURRENT_PACKAGES_DIR}/lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug
    FILES_MATCHING PATTERN "*d.prl"
)
file(INSTALL ${CURRENT_PACKAGES_DIR}/lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug
    FILES_MATCHING PATTERN "*d.pdb"
)
file(GLOB DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*d.lib")
file(REMOVE ${DEBUG_LIB_FILES})
file(GLOB DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*d.prl")
file(REMOVE ${DEBUG_LIB_FILES})
file(GLOB DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*d.pdb")
if(DEBUG_LIB_FILES)
    file(REMOVE ${DEBUG_LIB_FILES})
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Gamepad.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Gamepad.lib ${CURRENT_PACKAGES_DIR}/lib/Qt5Gamepad.lib)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Gamepad.prl)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Gamepad.prl ${CURRENT_PACKAGES_DIR}/lib/Qt5Gamepad.prl)
endif()
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qt5)
file(REMOVE ${BINARY_TOOLS})
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins")
file(GLOB_RECURSE DEBUG_PLUGINS
    "${CURRENT_PACKAGES_DIR}/plugins/*d.dll"
    "${CURRENT_PACKAGES_DIR}/plugins/*d.pdb"
)
foreach(file ${DEBUG_PLUGINS})
    get_filename_component(file_n ${file} NAME)
    file(RELATIVE_PATH file_rel "${CURRENT_PACKAGES_DIR}/plugins" ${file})
    get_filename_component(rel_dir ${file_rel} DIRECTORY)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/${rel_dir}")
    file(RENAME ${file} "${CURRENT_PACKAGES_DIR}/debug/plugins/${rel_dir}/${file_n}")
endforeach()

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/plugins/gamepads/xinputgamepad.dll)
    file(RENAME 
        ${CURRENT_PACKAGES_DIR}/debug/plugins/gamepads/xinputgamepad.dll
        ${CURRENT_PACKAGES_DIR}/plugins/gamepads/xinputgamepad.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/plugins/gamepads/xinputgamepad.pdb)
    file(RENAME 
        ${CURRENT_PACKAGES_DIR}/debug/plugins/gamepads/xinputgamepad.pdb
        ${CURRENT_PACKAGES_DIR}/plugins/gamepads/xinputgamepad.pdb)
endif()

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/lib/Qt5Bootstrap.lib AND EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrapd.lib)
    # QT bug: https://bugreports.qt.io/browse/QTBUG-55499
    # The release copy of Qt5Bootstrap.lib is not created when using -debug-and-release
    # Comments from Oswald Buddenhagen indicate this is an internal library, so simply removing the mismatch should be safe.
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/Qt5Bootstrapd.lib)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qt5)

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${CMAKE_CURRENT_LIST_DIR}/fixcmake.py
    WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/cmake
    LOGNAME fix-cmake
)

file(INSTALL ${SOURCE_PATH}/LICENSE.LGPLv3 DESTINATION  ${CURRENT_PACKAGES_DIR}/share/qt5 RENAME copyright)

vcpkg_copy_pdbs()

