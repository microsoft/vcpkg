vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qgis/QGIS
    REF final-3_12_0
    SHA512   aabf4ba11c6544e736ab57f0bd64b5f90b8952d919525626f532e4dc9b4fef292c63aec190f5cb6c3dbb59b9759655500e73643f5257a923d5c3c2cf9c3fb754
    HEAD_REF master
    PATCHES
        # Make qgis support python's debug library
        qgspython.patch
        # In vcpkg, qca's library name is qca, but qgis defaults to qca-qt5 or qca2-qt5, so add qca for easy searching
        qca.patch
)

#Fix UTF-8 to UTF-8-BOM For Chinese
if("utf8bom" IN_LIST FEATURES)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/Fix-process_function_template.patch"
        QUIET
    )
endif()

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})
set(PYTHON_EXECUTABLE ${PYTHON3})

list(APPEND QGIS_OPTIONS -DENABLE_TESTS:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_QTWEBKIT:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_GRASS7:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_QSPATIALITE:BOOL=ON)
list(APPEND QGIS_OPTIONS -DWITH_CUSTOM_WIDGETS:BOOL=ON)

##############################################################################
# Not implemented
if("server" IN_LIST FEATURES)
    list(APPEND QGIS_OPTIONS -DWITH_SERVER:BOOL=ON)
    if("bindings" IN_LIST FEATURES)
        list(APPEND QGIS_OPTIONS -DWITH_SERVER_PLUGINS:BOOL=ON)
    else()
        list(APPEND QGIS_OPTIONS -DWITH_SERVER_PLUGINS:BOOL=OFF)
    endif()
else()
    list(APPEND QGIS_OPTIONS -DWITH_SERVER:BOOL=OFF)
    list(APPEND QGIS_OPTIONS -DWITH_SERVER_PLUGINS:BOOL=OFF)
endif()
##############################################################################

if("3d" IN_LIST FEATURES)
    list(APPEND QGIS_OPTIONS -DWITH_3D:BOOL=ON)
else()
    list(APPEND QGIS_OPTIONS -DWITH_3D:BOOL=OFF)
endif()

if("quick" IN_LIST FEATURES)
    list(APPEND QGIS_OPTIONS -DWITH_QUICK:BOOL=ON)
else()
    list(APPEND QGIS_OPTIONS -DWITH_QUICK:BOOL=OFF)
endif()

# Configure debug and release library paths
macro(FIND_LIB_OPTIONS basename relname debname suffix libsuffix)
   file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/${VCPKG_TARGET_IMPORT_LIBRARY_PREFIX}${relname}${libsuffix}" ${basename}_LIBRARY_RELEASE)
   file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/${VCPKG_TARGET_IMPORT_LIBRARY_PREFIX}${debname}${libsuffix}" ${basename}_LIBRARY_DEBUG)
   if( ${basename}_LIBRARY_DEBUG AND ${basename}_LIBRARY_RELEASE AND NOT ${basename}_LIBRARY_DEBUG STREQUAL ${basename}_LIBRARY_RELEASE )
        list(APPEND QGIS_OPTIONS_RELEASE -D${basename}_${suffix}:FILEPATH=${${basename}_LIBRARY_RELEASE})
        list(APPEND QGIS_OPTIONS_DEBUG -D${basename}_${suffix}:FILEPATH=${${basename}_LIBRARY_DEBUG})
   elseif( ${basename}_LIBRARY_RELEASE )
        list(APPEND QGIS_OPTIONS -D${basename}_${suffix}:FILEPATH=${${basename}_LIBRARY_RELEASE})
   elseif( ${basename}_LIBRARY_DEBUG )
        list(APPEND QGIS_OPTIONS -D${basename}_${suffix}:FILEPATH=${${basename}_LIBRARY_DEBUG})
   endif()
endmacro()

if(VCPKG_TARGET_IS_WINDOWS)
    ##############################################################################
    #Install pip
    if(NOT EXISTS "${PYTHON3_PATH}/Scripts/pip.exe")
        MESSAGE(STATUS  "Install pip for Python Begin ...")
        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_CURRENT_LIST_DIR}/enableInstallPIP.py "${PYTHON3_PATH}"
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME pip
        )

        vcpkg_download_distfile(
            GET_PIP_PATH
            URLS https://bootstrap.pypa.io/3.4/get-pip.py
            FILENAME get-pip.py
            SHA512  3272604fc1d63725266e6bef87faa4905d06018839ecfdbe8d162b7175a9b3d56004c4eb7e979fe85e884fc3b8dcc509a6b26e7893eaf33b0efe608b444d64cf
        )

        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" "${GET_PIP_PATH}"
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME pip
        )

        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade pip
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME pip
        )
        MESSAGE(STATUS  "Install pip for Python End")
    endif (NOT EXISTS "${PYTHON3_PATH}/Scripts/pip.exe")
    ##############################################################################

    ##############################################################################
    #Install sip
    if(NOT EXISTS "${PYTHON3_PATH}/Lib/site-packages/sip.pyd")
        MESSAGE(STATUS  "Install sip for Python Begin ...")
        set(SIP_VERSION "4.19.21")
        vcpkg_download_distfile(
            SIP_PATH
            URLS https://www.riverbankcomputing.com/static/Downloads/sip/${SIP_VERSION}/sip-${SIP_VERSION}.tar.gz
            FILENAME sip-${SIP_VERSION}.tar.gz
            SHA512  441e1fe6b3eb6820638f9b4436e820da39b72dd70b402afa5237979ac671978c081d92e1e78920bb754bbc66b159bad08edb3bbb497b7e72dee6ff1d69cd1b60
        )

        vcpkg_extract_source_archive(
             ${SIP_PATH} ${PYTHON3_PATH}
        )

        set(SIP_PATH ${PYTHON3_PATH}/sip-${SIP_VERSION})
        file(COPY "${SIP_PATH}/siputils.py" DESTINATION "${PYTHON3_PATH}")
        file(GLOB PYTHON_INCLUDE ${CURRENT_INSTALLED_DIR}/include/python3.7/*.h)
        file(COPY ${PYTHON_INCLUDE} DESTINATION "${PYTHON3_PATH}/Include")
        file(COPY "${CURRENT_INSTALLED_DIR}/lib/python37.lib" DESTINATION "${PYTHON3_PATH}/libs")

        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" configure.py
            WORKING_DIRECTORY ${SIP_PATH}
            LOGNAME pip
        )

        find_program(NMAKE nmake REQUIRED)
        vcpkg_execute_required_process(
            COMMAND ${NMAKE} -f Makefile install
            WORKING_DIRECTORY ${SIP_PATH}
            LOGNAME pip
        )

        file(REMOVE_RECURSE "${PYTHON3_PATH}/siputils.py")
        file(REMOVE_RECURSE "${PYTHON3_PATH}/sip-${SIP_VERSION}.tar.gz.extracted")
        file(REMOVE_RECURSE "${SIP_PATH}")
        MESSAGE(STATUS  "Install sip for Python End")
    endif (NOT EXISTS "${PYTHON3_PATH}/Lib/site-packages/sip.pyd")

    #Install pyqt5 pyqt3d qscintilla
    if(NOT EXISTS "${PYTHON3_PATH}/Scripts/pyuic5.exe")
        MESSAGE(STATUS  "Install PyQt5 for Python Begin ...")
        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" -m pip install PyQt5 PyQt5-sip QScintilla PyQt3D
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME pip
        )
        MESSAGE(STATUS  "Install PyQt5 for Python End")
    endif (NOT EXISTS "${PYTHON3_PATH}/Scripts/pyuic5.exe")

    #Install pyqt5's and pyqt3d's sip files
    if("bindings" IN_LIST FEATURES)
        EXECUTE_PROCESS(COMMAND ${PYTHON_EXECUTABLE} "${SOURCE_PATH}/cmake/FindSIP.py" OUTPUT_VARIABLE sip_config)
        if(sip_config)
            STRING(REGEX REPLACE ".*\ndefault_sip_dir:([^\n]+).*$" "\\1" SIP_DEFAULT_SIP_DIR ${sip_config})
        endif(sip_config)

        if( SIP_DEFAULT_SIP_DIR )
            if(NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/QtCore/QtCoremod.sip")
                MESSAGE(STATUS  "Install PyQt5 sip for Python Begin ...")
                set(PYQT5_VERSION "5.13.2")
                vcpkg_download_distfile(
                    PYQT5_PATH
                    URLS https://www.riverbankcomputing.com/static/Downloads/PyQt5/${PYQT5_VERSION}/PyQt5-${PYQT5_VERSION}.tar.gz
                    FILENAME PyQt5-${PYQT5_VERSION}.tar.gz
                    SHA512  9a16450d8fe2a7e94e182ebb03cc785c6de516e356251753abfb79af3958230043f2db59750cde0a6f1fd6cf5568eb8b7ae76d5a3fbcfe9f7807e02867973b55
                )

                vcpkg_extract_source_archive(
                     ${PYQT5_PATH} ${PYTHON3_PATH}
                )

                set(PYQT5_PATH ${PYTHON3_PATH}/PyQt5_gpl-${PYQT5_VERSION})
                file(GLOB PYQT5_SIP ${PYQT5_PATH}/sip/*)
                file(COPY ${PYQT5_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )

                file(REMOVE_RECURSE ${PYTHON3_PATH}/PyQt5_gpl-${PYQT5_VERSION}.tar.gz.extracted)
                file(REMOVE_RECURSE ${PYQT5_PATH})
                MESSAGE(STATUS  "Install PyQt5 sip for Python End")
            endif (NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/QtCore/QtCoremod.sip")

            if("3d" IN_LIST FEATURES)
                if(NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/Qt3DCore/Qt3DCoremod.sip")
                    MESSAGE(STATUS  "Install PyQt3D sip for Python Begin ...")
                    set(PYQT3D_VERSION "5.13.1")
                    vcpkg_download_distfile(
                        PYQT3D_PATH
                        URLS https://www.riverbankcomputing.com/static/Downloads/PYQT3D/${PYQT3D_VERSION}/PYQT3D-${PYQT3D_VERSION}.tar.gz
                        FILENAME PYQT3D-${PYQT3D_VERSION}.tar.gz
                        SHA512  5361ab1a475b28ae37145e9caa35b2cbabec789d974c0442b93be5fa291607c79f0a4e50a52b757c2c7277f518e7f889c1edcdde1050effd7a61dc801b85f412
                    )
                    
                    vcpkg_extract_source_archive(
                         ${PYQT3D_PATH} ${PYTHON3_PATH}
                    )

                    set(PYQT3D_PATH ${PYTHON3_PATH}/PYQT3D_gpl-${PYQT3D_VERSION})
                    file(GLOB PYQT3D_SIP ${PYQT3D_PATH}/sip/*)
                    file(COPY ${PYQT3D_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )
                        
                    file(REMOVE_RECURSE ${PYTHON3_PATH}/PYQT3D_gpl-${PYQT3D_VERSION}.tar.gz.extracted)
                    file(REMOVE_RECURSE ${PYQT3D_PATH})
                    MESSAGE(STATUS  "Install PyQt3D sip for Python End")
                endif (NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/Qt3DCore/Qt3DCoremod.sip")
            endif()

            list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=ON)
        else()
            list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=OFF)
        endif()
    else()
        list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=OFF)
    endif()
    ##############################################################################

    ##############################################################################
    #Fix UTF-8 to UTF-8-BOM For Chinese
    if("utf8bom" IN_LIST FEATURES)
        if(NOT EXISTS "${PYTHON3_PATH}/Scripts/chardetect.exe")
            MESSAGE(STATUS  "Install chardet for Python Begin ...")
            vcpkg_execute_required_process(
                COMMAND "${PYTHON_EXECUTABLE}" -m pip install chardet
                WORKING_DIRECTORY ${PYTHON3_PATH}
                LOGNAME pip
            )
            MESSAGE(STATUS  "Install chardet for Python End")
        endif (NOT EXISTS "${PYTHON3_PATH}/Scripts/chardetect.exe")

        MESSAGE(STATUS  "Change SourceFile Encoding to UTF-8-BOM Begin ...")
        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_CURRENT_LIST_DIR}/UTF82UTF8-BOM.py "${SOURCE_PATH}/src"
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME UTF82UTF8-BOM
        )

        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" UTF82UTF8-BOM.py "${SOURCE_PATH}/tests/src"
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            LOGNAME UTF82UTF8-BOM
        )
        MESSAGE(STATUS  "Change SourceFile Encoding to UTF-8-BOM End")
    endif()
    ##############################################################################

    # flex and bison for ANGLE library
    list(APPEND QGIS_OPTIONS -DBISON_EXECUTABLE="${BISON}")
    list(APPEND QGIS_OPTIONS -DFLEX_EXECUTABLE="${FLEX}")

    list(APPEND QGIS_OPTIONS -DPYUIC_PROGRAM=${PYTHON3_PATH}/Scripts/pyuic5.exe)
    list(APPEND QGIS_OPTIONS -DPYRCC_PROGRAM=${PYTHON3_PATH}/Scripts/pyrcc5.exe)
    list(APPEND QGIS_OPTIONS -DQT_LRELEASE_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-tools/bin/lrelease.exe)

    if("quick" IN_LIST FEATURES)
        list(APPEND QGIS_OPTIONS -DQMLPLUGINDUMP_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/bin/qmlplugindump.exe)
    endif()

    # qgis_gui depends on Qt5UiTools, and Qt5UiTools is a static library.
    # If Qt5_EXCLUDE_STATIC_DEPENDENCIES is not set, it will add the QT release library that it depends on.
    # so that in debug mode, it will reference both the qt debug library and the release library.
    # In Debug mode, add Qt5_EXCLUDE_STATIC_DEPENDENCIES to avoid this bug
    list(APPEND QGIS_OPTIONS_DEBUG -DQt5_EXCLUDE_STATIC_DEPENDENCIES:BOOL=ON)

    FIND_LIB_OPTIONS(GDAL gdal gdald LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(GEOS geos_c geos_cd LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(GSL gsl gsld LIB ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(GSLCBLAS gslcblas gslcblasd LIB ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(POSTGRES libpq libpq LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(PROJ proj proj_d LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(PYTHON python37 python37_d LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QCA qca qcad LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QWT qwt qwtd LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QTKEYCHAIN qt5keychain qt5keychaind LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QSCINTILLA qscintilla2_qt5 qscintilla2_qt5d LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
    if("server" IN_LIST FEATURES)
        FIND_LIB_OPTIONS(FCGI libfcgi libfcgi LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
        list(APPEND QGIS_OPTIONS -DFCGI_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include/fastcgi")
    endif()

    set(SIDX_LIB_NAME spatialindex)
    if( VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" )
        set( SIDX_LIB_NAME "spatialindex-64" )
    else()
        set( SIDX_LIB_NAME "spatialindex-32"  )
    endif()
    FIND_LIB_OPTIONS(SPATIALINDEX ${SIDX_LIB_NAME} ${SIDX_LIB_NAME}d LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) # Build in UNIX
    macro(INSTALL_PROGRAM program)
        if(VCPKG_TARGET_IS_OSX)
            message(STATUS "brew install ${program}")
            vcpkg_execute_required_process(
              COMMAND brew install ${program}
              WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
            )
        else()
            message(STATUS "sudo apt-get install ${program}")
            vcpkg_execute_required_process(
              COMMAND sudo apt-get install -y ${program}
              WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
            )
        endif()
    endmacro()

    find_program(PIP3 pip3)
    if (NOT PIP3)
        INSTALL_PROGRAM(python3-pip)
    endif()

    vcpkg_execute_required_process(
        COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade pip
        WORKING_DIRECTORY ${PYTHON3_PATH}
        LOGNAME pip
    )

    vcpkg_execute_required_process(
        COMMAND "${PYTHON_EXECUTABLE}" -m pip install sip PyQt5 PyQt5-sip QScintilla PyQt3D
        WORKING_DIRECTORY ${PYTHON3_PATH}
        LOGNAME pip
    )

    find_program(PYUIC5 pyuic5)
    if (NOT PYUIC5)
        INSTALL_PROGRAM(pyqt5-dev-tools)
    endif()

    find_program(PYRCC5 pyrcc5)

    list(APPEND QGIS_OPTIONS_DEBUG -DQT_INSTALL_LIBS:PATH=${CURRENT_INSTALLED_DIR}/debug/lib)
    list(APPEND QGIS_OPTIONS_RELEASE -DQT_INSTALL_LIBS:PATH=${CURRENT_INSTALLED_DIR}/lib)
    list(APPEND QGIS_OPTIONS -DGDAL_CONFIG=" ")
    list(APPEND QGIS_OPTIONS -DGDAL_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include)
    FIND_LIB_OPTIONS(GDAL gdal gdal LIBRARY ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
    list(APPEND QGIS_OPTIONS -DGEOS_CONFIG=" ")
    FIND_LIB_OPTIONS(GEOS geos_c geos_cd LIBRARY ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    list(APPEND QGIS_OPTIONS -DGSL_CONFIG=" ")
    list(APPEND QGIS_OPTIONS -DGSL_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include)
    list(APPEND QGIS_OPTIONS_DEBUG -DGSL_LIBRARIES:FILEPATH=${CURRENT_INSTALLED_DIR}/debug/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}gsld${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX};${CURRENT_INSTALLED_DIR}/debug/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}gslcblasd${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    list(APPEND QGIS_OPTIONS_RELEASE -DGSL_LIBRARIES:FILEPATH="${CURRENT_INSTALLED_DIR}/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}gsl${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} ${CURRENT_INSTALLED_DIR}/lib/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}gslcblas${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    list(APPEND QGIS_OPTIONS -DPYTHON_INCLUDE_PATH:PATH=${CURRENT_INSTALLED_DIR}/include/python3.7m)
    FIND_LIB_OPTIONS(PYTHON python3.7m python3.7dm LIBRARY ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QTKEYCHAIN qt5keychain qt5keychaind LIBRARY  ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    if("server" IN_LIST FEATURES)
        #FIND_LIB_OPTIONS(FCGI fcgi fcgi LIBRARY ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
        #list(APPEND QGIS_OPTIONS -DFCGI_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include/fastcgi")
    endif()

    FIND_LIB_OPTIONS(SPATIALINDEX spatialindex spatialindexd LIBRARY ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${QGIS_OPTIONS} 
    OPTIONS_DEBUG ${QGIS_OPTIONS_DEBUG}
    OPTIONS_RELEASE ${QGIS_OPTIONS_RELEASE}
)

vcpkg_install_cmake()

# handle qgis tools and plugins
function(copy_path basepath)
    file(GLOB ${basepath}_PATH ${CURRENT_PACKAGES_DIR}/${basepath}/*)
    if( ${basepath}_PATH )
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/${basepath})
        file(COPY ${${basepath}_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/${basepath})
    endif()

    if(EXISTS "${CURRENT_PACKAGES_DIR}/${basepath}/")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/${basepath}/)
    endif()

    file(GLOB ${basepath}_DEBUG_PATH ${CURRENT_PACKAGES_DIR}/debug/${basepath}/*)
    if( ${basepath}_DEBUG_PATH )
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/${basepath})
        file(COPY ${${basepath}_DEBUG_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/${basepath})
    endif()

    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/${basepath}/")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/${basepath}/)
    endif()
endfunction()

file(GLOB QGIS_CMAKE_PATH ${CURRENT_PACKAGES_DIR}/*.cmake)
if(QGIS_CMAKE_PATH)
    file(COPY ${QGIS_CMAKE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    file(REMOVE_RECURSE ${QGIS_CMAKE_PATH})
endif()
file(GLOB QGIS_CMAKE_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/*.cmake)
if( QGIS_CMAKE_PATH_DEBUG )
    file(REMOVE_RECURSE ${QGIS_CMAKE_PATH_DEBUG})
endif()

file(GLOB QGIS_TOOL_PATH ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if(QGIS_TOOL_PATH)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
    file(COPY ${QGIS_TOOL_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
    file(REMOVE_RECURSE ${QGIS_TOOL_PATH})
    file(GLOB QGIS_TOOL_PATH ${CURRENT_PACKAGES_DIR}/bin/* )
    file(COPY ${QGIS_TOOL_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin)
endif()

file(GLOB QGIS_TOOL_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/debug/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})
if(QGIS_TOOL_PATH_DEBUG)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
    file(COPY ${QGIS_TOOL_PATH_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
    file(REMOVE_RECURSE ${QGIS_TOOL_PATH_DEBUG})
    file(GLOB QGIS_TOOL_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/* )
    file(COPY ${QGIS_TOOL_PATH_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
endif()

copy_path(doc)
copy_path(i18n)
copy_path(icons)
copy_path(images)
copy_path(plugins)
copy_path(python)
if("quick" IN_LIST FEATURES)
    copy_path(qml)
endif()
copy_path(resources)
if("server" IN_LIST FEATURES)
    copy_path(server)
endif()
copy_path(svg)

if(VCPKG_TARGET_IS_WINDOWS)
    # Extend vcpkg_copy_tool_dependencies to support the export of dll and exe dependencies in different directories to the same directory,
    # and support the copy of debug dependencies
    function(vcpkg_copy_tool_dependencies_ex TOOL_DIR OUTPUT_DIR SEARCH_DIR)
        macro(search_for_dependencies PATH_TO_SEARCH)
            file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
            foreach(TOOL ${TOOLS})
                execute_process(COMMAND powershell -noprofile -executionpolicy Bypass -nologo
                    -file ${CMAKE_CURRENT_LIST_DIR}/applocal.ps1
                    -targetBinary ${TOOL}
                    -installedDir ${PATH_TO_SEARCH}
                    -outputDir    ${OUTPUT_DIR}
                    OUTPUT_VARIABLE OUT)
            endforeach()
        endmacro()
        search_for_dependencies(${CURRENT_PACKAGES_DIR}/${SEARCH_DIR})
        search_for_dependencies(${CURRENT_INSTALLED_DIR}/${SEARCH_DIR})
    endfunction()

    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/plugins ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
    if("server" IN_LIST FEATURES)
        vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/server ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
        vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/server ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
    endif()
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)