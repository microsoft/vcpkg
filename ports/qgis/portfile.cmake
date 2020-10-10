set(QT_VERSION 5.15.0)
set(QSCINTILLA_VERSION 2.11.4)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if("ltr" IN_LIST FEATURES)
    set(QGIS_REF final-3_10_10)
    set(QGIS_SHA512 3b45498af9915491553963f16786f0fb7a6491d564415685a78241324dcff84cbc7bbe9acad1a9bf8fde444a7f09e87b372d60441bf850f35d729adf2e2f8af3)
else()
    set(QGIS_REF final-3_14_16)
    set(QGIS_SHA512 fbb853582a44980a1a3a5c5d1a5e2c7b59d2c12a37b37ad1ed32daa44c75a64196763f948fa6915247e98ddebf5d9ed0bc083599a2dee25299e8accc3037ed07)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qgis/QGIS
    REF ${QGIS_REF}
    SHA512   ${QGIS_SHA512}
    HEAD_REF master
    PATCHES
        # Make qgis support python's debug library
        qgspython.patch
        # In vcpkg, qca's library name is qca, but qgis defaults to qca-qt5 or qca2-qt5, so add qca for easy searching
        qca.patch
        fixpython38.patch
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})
vcpkg_add_to_path(${PYTHON3_PATH}/Scripts)
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

if("pip-mirrors" IN_LIST FEATURES)
    set(PIP_MIRRORS -i https://mirrors.aliyun.com/pypi/simple)
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
    if("quick" IN_LIST FEATURES)
        vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/bin)
        vcpkg_add_to_path(${CURRENT_INSTALLED_DIR}/debug/bin)
        if("ltr" IN_LIST FEATURES)
            vcpkg_apply_patches(
                    SOURCE_PATH ${SOURCE_PATH}
                    PATCHES "${CMAKE_CURRENT_LIST_DIR}/qgsquick-ltr.patch"
                    QUIET
                )
        else()
            vcpkg_apply_patches(
                    SOURCE_PATH ${SOURCE_PATH}
                    PATCHES "${CMAKE_CURRENT_LIST_DIR}/qgsquick.patch"
                    QUIET
                )
        endif()
    endif()

    ##############################################################################
    #Install pip
    if(NOT EXISTS "${PYTHON3_PATH}/Scripts/pip.exe")
        MESSAGE(STATUS  "Install pip for Python Begin ...")
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
            COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade pip ${PIP_MIRRORS}
            WORKING_DIRECTORY ${PYTHON3_PATH}
            LOGNAME pip
        )
        MESSAGE(STATUS  "Install pip for Python End")
    endif (NOT EXISTS "${PYTHON3_PATH}/Scripts/pip.exe")
    ##############################################################################

    ##############################################################################
    #Install sip
    if("sip5" IN_LIST FEATURES)
        if(NOT EXISTS "${PYTHON3_PATH}/Scripts/sip5.exe")
            MESSAGE(STATUS  "Install sip for Python Begin ...")
            file(GLOB PYTHON_INCLUDE ${CURRENT_INSTALLED_DIR}/include/python3.8/*)
            file(COPY ${PYTHON_INCLUDE} DESTINATION "${PYTHON3_PATH}/Include")
            file(COPY "${CURRENT_INSTALLED_DIR}/lib/python38.lib" DESTINATION "${PYTHON3_PATH}/libs")
        
            vcpkg_execute_required_process(
                COMMAND "${PYTHON_EXECUTABLE}" -m pip install sip ${PIP_MIRRORS}
                WORKING_DIRECTORY ${PYTHON3_PATH}
                LOGNAME pip
            )
            MESSAGE(STATUS  "Install sip for Python End")
        endif (NOT EXISTS "${PYTHON3_PATH}/Scripts/sip5.exe")
    else()
        if(NOT EXISTS "${PYTHON3_PATH}/Lib/site-packages/sip.pyd")
            MESSAGE(STATUS  "Install sip for Python Begin ...")
            set(SIP_VERSION "4.19.24")
            vcpkg_download_distfile(
                SIP_PATH
                URLS https://www.riverbankcomputing.com/static/Downloads/sip/${SIP_VERSION}/sip-${SIP_VERSION}.tar.gz
                FILENAME sip-${SIP_VERSION}.tar.gz
                SHA512  c9acf8c66da6ff24ffaeed254c11deabbc587cea0eb50164f2016199af30b85980f96a2d754ae5e7fe080f9076673b1abc82e2a6a41ff2ac442fb2b326fca1c0
            )

            vcpkg_extract_source_archive(
                 ${SIP_PATH} ${PYTHON3_PATH}
            )

            set(SIP_PATH ${PYTHON3_PATH}/sip-${SIP_VERSION})
            file(COPY "${SIP_PATH}/siputils.py" DESTINATION "${PYTHON3_PATH}")
            file(GLOB PYTHON_INCLUDE ${CURRENT_INSTALLED_DIR}/include/python3.8/*)
            file(COPY ${PYTHON_INCLUDE} DESTINATION "${PYTHON3_PATH}/Include")
            file(COPY "${CURRENT_INSTALLED_DIR}/lib/python38.lib" DESTINATION "${PYTHON3_PATH}/libs")

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
    endif ("sip5" IN_LIST FEATURES)

    #Install pyqt5 pyqt3d qscintilla
    if(NOT EXISTS "${PYTHON3_PATH}/Scripts/pyuic5.exe")
        MESSAGE(STATUS  "Install PyQt5 for Python Begin ...")
        vcpkg_execute_required_process(
            COMMAND "${PYTHON_EXECUTABLE}" -m pip install PyQt5==${QT_VERSION} PyQt5-sip QScintilla==${QSCINTILLA_VERSION} PyQt3D==${QT_VERSION} ${PIP_MIRRORS}
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
                set(PYQT5_FILENAME "PyQt5")
                set(PYQT5_SHA512 35bcfef4d7ccfee04c1c4409d2af3d862f1e8e46d6ce743bfcfbaf43d2046bc58317824b0840f3db460ad280d1b7e896812268b36225198e916a1d9ea86823a9)
                vcpkg_download_distfile(
                    PYQT5_PATH
                    URLS https://files.pythonhosted.org/packages/8c/90/82c62bbbadcca98e8c6fa84f1a638de1ed1c89e85368241e9cc43fcbc320/${PYQT5_FILENAME}-${QT_VERSION}.tar.gz
                    FILENAME ${PYQT5_FILENAME}-${QT_VERSION}.tar.gz
                    SHA512  ${PYQT5_SHA512}
                )

                vcpkg_extract_source_archive(
                     ${PYQT5_PATH} ${PYTHON3_PATH}
                )

                set(PYQT5_PATH ${PYTHON3_PATH}/${PYQT5_FILENAME}-${QT_VERSION})
                file(GLOB PYQT5_SIP ${PYQT5_PATH}/sip/*)
                file(COPY ${PYQT5_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )

                file(REMOVE_RECURSE ${PYTHON3_PATH}/${PYQT5_FILENAME}-${QT_VERSION}.tar.gz.extracted)
                file(REMOVE_RECURSE ${PYQT5_PATH})
                MESSAGE(STATUS  "Install PyQt5 sip for Python End")
            endif (NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/QtCore/QtCoremod.sip")

            if("3d" IN_LIST FEATURES)
                if(NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/Qt3DCore/Qt3DCoremod.sip")
                    MESSAGE(STATUS  "Install PyQt3D sip for Python Begin ...")
                    set(PYQT3D_FILENAME "PyQt3D")
                    set(PYQT3D_SHA512 5420490cc9f9a0812d0b7ee727ea1d4b118d90cb30df36aaefe98d49688b3e43b26b57e2005c96cbb7b0935676cd7aaac46b1e1730ac677d20d372989ea4b836)
                    vcpkg_download_distfile(
                        PYQT3D_PATH
                        URLS https://files.pythonhosted.org/packages/ac/05/387684926415213c9701989a0f37d72ee6d79a2b1571ffea5a79c0d923a2/${PYQT3D_FILENAME}-${QT_VERSION}.tar.gz
                        FILENAME ${PYQT3D_FILENAME}-${QT_VERSION}.tar.gz
                        SHA512  ${PYQT3D_SHA512}
                    )
                    
                    vcpkg_extract_source_archive(
                         ${PYQT3D_PATH} ${PYTHON3_PATH}
                    )

                    set(PYQT3D_PATH ${PYTHON3_PATH}/${PYQT3D_FILENAME}-${QT_VERSION})
                    file(GLOB PYQT3D_SIP ${PYQT3D_PATH}/sip/*)
                    file(COPY ${PYQT3D_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )
                        
                    file(REMOVE_RECURSE ${PYTHON3_PATH}/${PYQT3D_FILENAME}-${QT_VERSION}.tar.gz.extracted)
                    file(REMOVE_RECURSE ${PYQT3D_PATH})
                    MESSAGE(STATUS  "Install PyQt3D sip for Python End")
                endif (NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/Qt3DCore/Qt3DCoremod.sip")
            endif()

            #Install qgis dependencies Module for Python
            #MESSAGE(STATUS  "Install qgis dependencies Module for Python Begin ...")
            #set(PROJ_DIR ${CURRENT_INSTALLED_DIR}/include
            #vcpkg_execute_required_process(
            #    COMMAND "${PYTHON_EXECUTABLE}" -m pip install pyyaml psycopg2-binary numpy pyproj==2.6.1.post1 owslib jinja2 GDAL==2.4.4 ${PIP_MIRRORS}
            #    WORKING_DIRECTORY ${PYTHON3_PATH}
            #    LOGNAME pip
            #)
            #MESSAGE(STATUS  "Install qgis dependencies Module for Python End")
            list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=ON)
        else()
            list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=OFF)
        endif()
    else()
        list(APPEND QGIS_OPTIONS -DWITH_BINDINGS:BOOL=OFF)
    endif()

    ##############################################################################

    # flex and bison for ANGLE library
    list(APPEND QGIS_OPTIONS -DBISON_EXECUTABLE="${BISON}")
    list(APPEND QGIS_OPTIONS -DFLEX_EXECUTABLE="${FLEX}")

    list(APPEND QGIS_OPTIONS -DPYUIC_PROGRAM=${PYTHON3_PATH}/Scripts/pyuic5.exe)
    list(APPEND QGIS_OPTIONS -DPYRCC_PROGRAM=${PYTHON3_PATH}/Scripts/pyrcc5.exe)
    list(APPEND QGIS_OPTIONS -DQT_LRELEASE_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-tools/bin/lrelease.exe)

    if("quick" IN_LIST FEATURES)
        list(APPEND QGIS_OPTIONS_DEBUG -DQMLPLUGINDUMP_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5/debug/bin/qmlplugindump.exe)
        list(APPEND QGIS_OPTIONS_RELEASE -DQMLPLUGINDUMP_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-declarative/bin/qmlplugindump.exe)
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
    FIND_LIB_OPTIONS(PYTHON python38 python38_d LIBRARY ${VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX})
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
        set( SIDX_LIB_NAME "spatialindex-32" )
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
        COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade pip ${PIP_MIRRORS}
        WORKING_DIRECTORY ${PYTHON3_PATH}
        LOGNAME pip
    )

    vcpkg_execute_required_process(
        COMMAND "${PYTHON_EXECUTABLE}" -m pip install sip PyQt5==${QT_VERSION} PyQt5-sip QScintilla==${QSCINTILLA_VERSION} PyQt3D==${QT_VERSION} ${PIP_MIRRORS}
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
    list(APPEND QGIS_OPTIONS -DPYTHON_INCLUDE_PATH:PATH=${CURRENT_INSTALLED_DIR}/include/python3.8m)
    FIND_LIB_OPTIONS(PYTHON python3.8m python3.8dm LIBRARY ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    FIND_LIB_OPTIONS(QTKEYCHAIN qt5keychain qt5keychaind LIBRARY  ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    if("server" IN_LIST FEATURES)
        FIND_LIB_OPTIONS(FCGI fcgi fcgi LIBRARY ${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX})
        list(APPEND QGIS_OPTIONS -DFCGI_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include/fastcgi")
    endif()

    FIND_LIB_OPTIONS(SPATIALINDEX spatialindex spatialindexd LIBRARY ${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
else() # Other build system
  message(FATAL_ERROR "Unsupport build system.")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    #PREFER_NINJA
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

    if("debug-tools" IN_LIST FEATURES)
        file(GLOB ${basepath}_DEBUG_PATH ${CURRENT_PACKAGES_DIR}/debug/${basepath}/*)
        if( ${basepath}_DEBUG_PATH )
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/${basepath})
            file(COPY ${${basepath}_DEBUG_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/${basepath})
        endif()
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
    if("debug-tools" IN_LIST FEATURES)
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
        file(COPY ${QGIS_TOOL_PATH_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
        file(REMOVE_RECURSE ${QGIS_TOOL_PATH_DEBUG})
        file(GLOB QGIS_TOOL_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/* )
        file(COPY ${QGIS_TOOL_PATH_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin)
    else()
        file(REMOVE_RECURSE ${QGIS_TOOL_PATH_DEBUG})
    endif()
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
        find_program(PS_EXE powershell PATHS ${DOWNLOADS}/tool)
        if (PS_EXE-NOTFOUND)
            message(FATAL_ERROR "Could not find powershell in vcpkg tools, please open an issue to report this.")
        endif()
        macro(search_for_dependencies PATH_TO_SEARCH)
            file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
            foreach(TOOL ${TOOLS})
                vcpkg_execute_required_process(
                    COMMAND ${PS_EXE} -noprofile -executionpolicy Bypass -nologo
                        -file ${CMAKE_CURRENT_LIST_DIR}/applocal.ps1
                        -targetBinary ${TOOL}
                        -installedDir ${PATH_TO_SEARCH}
                        -outputDir    ${OUTPUT_DIR}
                    WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
                    LOGNAME copy-tool-dependencies
                )
            endforeach()
        endmacro()
        search_for_dependencies(${CURRENT_PACKAGES_DIR}/${SEARCH_DIR})
        search_for_dependencies(${CURRENT_INSTALLED_DIR}/${SEARCH_DIR})
    endfunction()

    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
    vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
    if("debug-tools" IN_LIST FEATURES)
        vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
        vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/plugins ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
    endif()
    if("server" IN_LIST FEATURES)
        vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/tools/${PORT}/server ${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin bin)
        if("debug-tools" IN_LIST FEATURES)
            vcpkg_copy_tool_dependencies_ex(${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/server ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/bin debug/bin)
        endif()
    endif()
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)