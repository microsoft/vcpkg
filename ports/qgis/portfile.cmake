include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qgis/QGIS
    REF final-3_8_2
    SHA512   09c54cc9afc21f792cedd413f0f752480ecabae37c54625c55f45473b1241893b4e55ede38894794d08819c3107cb07e2879ccce909a74e1295d17e049d7c737
    HEAD_REF master
	PATCHES
		# Make qgis support python's debug library
		qgspython.patch
		# In vcpkg, qca's library name is qca, but qgis defaults to qca-qt5 or qca2-qt5, so add qca for easy searching
		qca.patch
		#The postgres, ogr, wms, arcgisrest providers plugin and oauth2 will be compiled into a static library and a dynamic library at the same time. It is possible to use the moc to generate the same file at compile time, which will cause compilation errors. So remove the static library build.
		static.patch
)

#Fix UTF-8 to UTF-8-BOM For Chinese
if("utf8bom" IN_LIST FEATURES)
	vcpkg_apply_patches(
		SOURCE_PATH ${SOURCE_PATH}
		PATCHES "${CMAKE_CURRENT_LIST_DIR}/Fix-process_function_template.patch"
		QUIET
	)
endif()

vcpkg_find_acquire_program(PYTHON3)

set(PYTHON_EXECUTABLE ${PYTHON3})
get_filename_component(PYTHON_PATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYTHON_PATH};${PYTHON_PATH}/Scripts")
set(PYTHONHOME ${PYTHON_PATH})

##############################################################################
#Install pip
if(NOT EXISTS "${PYTHON_PATH}/Scripts/pip.exe")
	MESSAGE(STATUS  "Install pip for Python Begin ...")
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_CURRENT_LIST_DIR}/enableInstallPIP.py "${PYTHON_PATH}"
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)

	vcpkg_download_distfile(
		GET_PIP_PATH
		URLS https://bootstrap.pypa.io/3.3/get-pip.py
		FILENAME get-pip.py
		SHA512  92e68525830bb23955a31cb19ebc3021ef16b6337eab83d5db2961b791283d2867207545faf83635f6027f2f7b7f8fee2c85f2cfd8e8267df25406474571c741
	)
	
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" "${GET_PIP_PATH}"
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)
	
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" -m pip install --upgrade pip
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)
	MESSAGE(STATUS  "Install pip for Python End")
endif (NOT EXISTS "${PYTHON_PATH}/Scripts/pip.exe")
##############################################################################

##############################################################################
#Install sip
if(NOT EXISTS "${PYTHON_PATH}/Lib/site-packages/sip.pyd")
	MESSAGE(STATUS  "Install sip for Python Begin ...")
	set(SIP_VERSION "4.19.18")
	vcpkg_download_distfile(
		SIP_PATH
		URLS https://www.riverbankcomputing.com/static/Downloads/sip/${SIP_VERSION}/sip-${SIP_VERSION}.tar.gz
		FILENAME sip-${SIP_VERSION}.tar.gz
		SHA512  e3c58cc6c38b277b3b9fd7adf33df91b47e0385e59d52c543e630a194d73d04d91e0a3845cb3973d1955f77049e75246fa7e6f544e02e1efe0086a297cf1d887
	)
	
	vcpkg_extract_source_archive(
		 ${SIP_PATH} ${PYTHON_PATH}
	)
	
	set(SIP_PATH ${PYTHON_PATH}/sip-${SIP_VERSION})
	file(COPY "${SIP_PATH}/siputils.py" DESTINATION "${PYTHON_PATH}")
	file(GLOB PYTHON_INCLUDE ${CURRENT_INSTALLED_DIR}/include/python3.7/*.h)
	file(COPY ${PYTHON_INCLUDE} DESTINATION "${PYTHON_PATH}/Include")
	file(COPY "${CURRENT_INSTALLED_DIR}/lib/python37.lib" DESTINATION "${PYTHON_PATH}/libs")
	
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
	
	file(REMOVE_RECURSE "${PYTHON_PATH}/siputils.py")
	file(REMOVE_RECURSE "${PYTHON_PATH}/sip-${SIP_VERSION}.tar.gz.extracted")
	file(REMOVE_RECURSE "${SIP_PATH}")
	MESSAGE(STATUS  "Install sip for Python End")
endif (NOT EXISTS "${PYTHON_PATH}/Lib/site-packages/sip.pyd")

#Install pyqt5 pyqt3d qscintilla
if(NOT EXISTS "${PYTHON_PATH}/Scripts/pyuic5.exe")
	MESSAGE(STATUS  "Install PyQt5 for Python Begin ...")
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" -m pip install PyQt5
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)
	
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" -m pip install PyQt5-sip
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)
	
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" -m pip install QScintilla
		WORKING_DIRECTORY ${PYTHON_PATH}
		LOGNAME pip
	)
	
	if("3d" IN_LIST FEATURES)
		vcpkg_execute_required_process(
			COMMAND "${PYTHON_EXECUTABLE}" -m pip install PyQt3D
			WORKING_DIRECTORY ${PYTHON_PATH}
			LOGNAME pip
		)
	endif()
	MESSAGE(STATUS  "Install PyQt5 for Python End")
endif (NOT EXISTS "${PYTHON_PATH}/Scripts/pyuic5.exe")

#Install pyqt5's and pyqt3d's sip files
if("bindings" IN_LIST FEATURES)
	EXECUTE_PROCESS(COMMAND ${PYTHON_EXECUTABLE} "${SOURCE_PATH}/cmake/FindSIP.py" OUTPUT_VARIABLE sip_config)
	if(sip_config)
		STRING(REGEX REPLACE ".*\ndefault_sip_dir:([^\n]+).*$" "\\1" SIP_DEFAULT_SIP_DIR ${sip_config})
	endif(sip_config)	
		
	if( SIP_DEFAULT_SIP_DIR )
		if(NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/QtCore/QtCoremod.sip")
			MESSAGE(STATUS  "Install PyQt5 sip for Python Begin ...")
			set(PYQT5_VERSION "5.13.0")
			vcpkg_download_distfile(
				PYQT5_PATH
				URLS https://www.riverbankcomputing.com/static/Downloads/PyQt5/${PYQT5_VERSION}/PyQt5_gpl-${PYQT5_VERSION}.tar.gz
				FILENAME PyQt5_gpl-${PYQT5_VERSION}.tar.gz
				SHA512  72cdd700956f8a5791fd38cac6a348f189eec9e69f3fd79a0c711ff49c770d4982fe62ec9057830d26abc4c12133922df915be0844449212f0bdf338fe1e4cb0
			)
			
			vcpkg_extract_source_archive(
				 ${PYQT5_PATH} ${PYTHON_PATH}
			)
			
			set(PYQT5_PATH ${PYTHON_PATH}/PyQt5_gpl-${PYQT5_VERSION})
			file(GLOB PYQT5_SIP ${PYQT5_PATH}/sip/*)
			file(COPY ${PYQT5_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )
				
			file(REMOVE_RECURSE ${PYTHON_PATH}/PyQt5_gpl-${PYQT5_VERSION}.tar.gz.extracted)
			file(REMOVE_RECURSE ${PYQT5_PATH})
			MESSAGE(STATUS  "Install PyQt5 sip for Python End")
		endif (NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/QtCore/QtCoremod.sip")

		if("3d" IN_LIST FEATURES)
			if(NOT EXISTS "${SIP_DEFAULT_SIP_DIR}/Qt3DCore/Qt3DCoremod.sip")
				MESSAGE(STATUS  "Install PyQt3D sip for Python Begin ...")
				set(PYQT3D_VERSION "5.13.0")
				vcpkg_download_distfile(
					PYQT3D_PATH
					URLS https://www.riverbankcomputing.com/static/Downloads/PYQT3D/${PYQT3D_VERSION}/PYQT3D_gpl-${PYQT3D_VERSION}.tar.gz
					FILENAME PYQT3D_gpl-${PYQT3D_VERSION}.tar.gz
					SHA512  49916c4eacf0373530500de217bac15716437347e16e6d93f4db4b064703d3181bad554f8f619729ec1de500c2bc15c6e52982a0dc53f3c0fc6792570e2eba44
				)
				
				vcpkg_extract_source_archive(
					 ${PYQT3D_PATH} ${PYTHON_PATH}
				)
				
				set(PYQT3D_PATH ${PYTHON_PATH}/PYQT3D_gpl-${PYQT3D_VERSION})
				file(GLOB PYQT3D_SIP ${PYQT3D_PATH}/sip/*)
				file(COPY ${PYQT3D_SIP} DESTINATION "${SIP_DEFAULT_SIP_DIR}" )
					
				file(REMOVE_RECURSE ${PYTHON_PATH}/PYQT3D_gpl-${PYQT3D_VERSION}.tar.gz.extracted)
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
	if(NOT EXISTS "${PYTHON_PATH}/Scripts/chardetect.exe")
		MESSAGE(STATUS  "Install chardet for Python Begin ...")
		vcpkg_execute_required_process(
			COMMAND "${PYTHON_EXECUTABLE}" -m pip install chardet
			WORKING_DIRECTORY ${PYTHON_PATH}
			LOGNAME pip
		)
		MESSAGE(STATUS  "Install chardet for Python End")
	endif (NOT EXISTS "${PYTHON_PATH}/Scripts/chardetect.exe")

	MESSAGE(STATUS  "Change SourceFile Encoding to UTF-8-BOM Begin ...")
	vcpkg_execute_required_process(
		COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_CURRENT_LIST_DIR}/UTF82UTF8-BOM.py "${SOURCE_PATH}/src"
		WORKING_DIRECTORY ${PYTHON_PATH}
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

if (CMAKE_HOST_WIN32)
	# flex and bison for ANGLE library
	vcpkg_find_acquire_program(FLEX)
	get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
	get_filename_component(FLEX_DIR ${FLEX_EXE_PATH} NAME)

	file(COPY ${FLEX_EXE_PATH} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools" )
	set(FLEX_TEMP "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-tools/${FLEX_DIR}")
	file(RENAME "${FLEX_TEMP}/win_bison.exe" "${FLEX_TEMP}/bison.exe")
	file(RENAME "${FLEX_TEMP}/win_flex.exe" "${FLEX_TEMP}/flex.exe")
	list(APPEND QGIS_OPTIONS -DBISON_EXECUTABLE="${FLEX_TEMP}/bison.exe")
	list(APPEND QGIS_OPTIONS -DFLEX_EXECUTABLE="${FLEX_TEMP}/flex.exe")
endif(CMAKE_HOST_WIN32)

list(APPEND QGIS_OPTIONS -DENABLE_TESTS:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_QTWEBKIT:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_GRASS7:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_QUICK:BOOL=OFF)
list(APPEND QGIS_OPTIONS -DWITH_QSPATIALITE:BOOL=ON)
list(APPEND QGIS_OPTIONS -DWITH_CUSTOM_WIDGETS:BOOL=ON)

##############################################################################
# Not implemented
#if("server" IN_LIST FEATURES)
#	list(APPEND QGIS_OPTIONS -DWITH_SERVER:BOOL=ON)
#else()
#	list(APPEND QGIS_OPTIONS -DWITH_SERVER:BOOL=OFF)
#endif()
list(APPEND QGIS_OPTIONS -DWITH_SERVER:BOOL=OFF)
##############################################################################

if("3d" IN_LIST FEATURES)
	list(APPEND QGIS_OPTIONS -DWITH_3D:BOOL=ON)
else()
	list(APPEND QGIS_OPTIONS -DWITH_3D:BOOL=OFF)
endif()

list(APPEND QGIS_OPTIONS -DPYUIC_PROGRAM=${PYTHON_PATH}/Scripts/pyuic5.exe)
list(APPEND QGIS_OPTIONS -DPYRCC_PROGRAM=${PYTHON_PATH}/Scripts/pyrcc5.exe)

# Configure debug and release library paths
macro(FIND_LIB_OPTIONS basename relname debname suffix)
   file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/lib/${relname}.lib" ${basename}_LIBRARY_RELEASE)
   file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/lib/${debname}.lib" ${basename}_LIBRARY_DEBUG)
   if( ${basename}_LIBRARY_DEBUG AND ${basename}_LIBRARY_RELEASE AND NOT ${basename}_LIBRARY_DEBUG STREQUAL ${basename}_LIBRARY_RELEASE )
		list(APPEND QGIS_OPTIONS_RELEASE -D${basename}_${suffix}="${${basename}_LIBRARY_RELEASE}")
		list(APPEND QGIS_OPTIONS_DEBUG -D${basename}_${suffix}="${${basename}_LIBRARY_DEBUG}")
   elseif( ${basename}_LIBRARY_RELEASE )
	    list(APPEND QGIS_OPTIONS -D${basename}_${suffix}="${${basename}_LIBRARY_RELEASE}")
   elseif( ${basename}_LIBRARY_DEBUG )
	    list(APPEND QGIS_OPTIONS -D${basename}_${suffix}="${${basename}_LIBRARY_DEBUG}")
   endif()
endmacro()

FIND_LIB_OPTIONS(GDAL gdal gdald LIBRARY)
FIND_LIB_OPTIONS(GEOS geos_c geos_cd LIBRARY)
FIND_LIB_OPTIONS(GSL gsl gsld LIB)
FIND_LIB_OPTIONS(GSLCBLAS gslcblas gslcblasd LIB)
FIND_LIB_OPTIONS(POSTGRES libpq libpqd LIBRARY)
FIND_LIB_OPTIONS(PROJ proj projd LIBRARY)
FIND_LIB_OPTIONS(PYTHON python37 python37_d LIBRARY)
FIND_LIB_OPTIONS(QCA qca qcad LIBRARY)
FIND_LIB_OPTIONS(QWT qwt qwtd LIBRARY)
FIND_LIB_OPTIONS(QTKEYCHAIN qt5keychain qt5keychaind LIBRARY)

set(SIDX_LIB_NAME spatialindex)
if (CMAKE_HOST_WIN32)
	if( VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" )
		set( SIDX_LIB_NAME "spatialindex-64" )
	else()
		set( SIDX_LIB_NAME "spatialindex-32"  )
	endif()
endif()
FIND_LIB_OPTIONS(SPATIALINDEX ${SIDX_LIB_NAME} ${SIDX_LIB_NAME}d LIBRARY)

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
		file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qgis/${basepath})
		file(COPY ${${basepath}_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qgis/${basepath})		
	endif()
	
	if(EXISTS "${CURRENT_PACKAGES_DIR}/${basepath}/")
		file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/${basepath}/)
	endif()
		
	file(GLOB ${basepath}_DEBUG_PATH ${CURRENT_PACKAGES_DIR}/debug/${basepath}/*)
	if( ${basepath}_DEBUG_PATH )
		file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/qgis/${basepath})
		file(COPY ${${basepath}_DEBUG_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/qgis/${basepath})		
	endif()
	
	if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/${basepath}/")
		file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/${basepath}/)
	endif()
endfunction()

file(GLOB QGIS_CMAKE_PATH ${CURRENT_PACKAGES_DIR}/*.cmake)
if(QGIS_CMAKE_PATH)
	file(COPY ${QGIS_CMAKE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake/qgis)
	file(REMOVE_RECURSE ${QGIS_CMAKE_PATH})
endif()
file(GLOB QGIS_CMAKE_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/*.cmake)
if( QGIS_CMAKE_PATH_DEBUG )
	file(REMOVE_RECURSE ${QGIS_CMAKE_PATH_DEBUG})
endif()

file(GLOB QGIS_TOOL_PATH ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/*.exe)
if(QGIS_TOOL_PATH)
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/qgis/bin)
	file(COPY ${QGIS_TOOL_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qgis/bin)
	file(REMOVE_RECURSE ${QGIS_TOOL_PATH})
endif()

file(GLOB QGIS_TOOL_PATH_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/*.exe)
if(QGIS_TOOL_PATH_DEBUG)
	file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools/qgis/bin)
	file(COPY ${QGIS_TOOL_PATH_DEBUG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/qgis/bin)
	file(REMOVE_RECURSE ${QGIS_TOOL_PATH_DEBUG})
endif()

copy_path(doc)
copy_path(i18n)
copy_path(icons)
copy_path(images)
copy_path(plugins)
copy_path(python)
copy_path(resources)
copy_path(svg)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qgis)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qgis/COPYING ${CURRENT_PACKAGES_DIR}/share/qgis/copyright)