message(STATUS "This TensorFlow port currently is experimental.")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
	message(FATAL_ERROR "TensorFlow does not support 32bit systems.")
endif()

set(TF_VERSION 2.3.0)

vcpkg_find_acquire_program(BAZEL)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${BAZEL_DIR})
set(ENV{BAZEL_BIN_PATH} "${BAZEL}")

function(tensorflow_try_remove_recurse_wait PATH_TO_REMOVE)
	file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	if(EXISTS "${PATH_TO_REMOVE}")
		execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
		file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	endif()
endfunction()

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_DIR "${GIT}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${GIT_DIR})

if(CMAKE_HOST_WIN32)
	vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash unzip patch diffutils libintl gzip coreutils mingw-w64-x86_64-python-numpy)
	vcpkg_add_to_path(${MSYS_ROOT}/usr/bin)
	set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

	set(ENV{BAZEL_SH} ${MSYS_ROOT}/usr/bin/bash.exe)
	set(ENV{BAZEL_VC} $ENV{VCInstallDir})
	set(ENV{BAZEL_VC_FULL_VERSION} $ENV{VCToolsVersion})

	#set(PYTHON3 "${MSYS_ROOT}/mingw64/bin/python3")
	# workaround: use local installation until bazel fix https://github.com/bazelbuild/bazel/pull/12002 is available
	find_package(Python3 COMPONENTS Interpreter)
	if(NOT Python3_Interpreter_FOUND)
		message(FATAL_ERROR "Can't find python 3. Please install and re-run vcpkg.")
	endif()
	set(PYTHON3 "${Python3_EXECUTABLE}")
else()
	vcpkg_find_acquire_program(PYTHON3)
	get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
	vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})

	if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
		vcpkg_execute_required_process(COMMAND sudo apt-get -y install python3-pip WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME install-pip-${TARGET_TRIPLET})
	endif()

	vcpkg_execute_required_process(COMMAND ${PYTHON3} -m pip install --user -U numpy WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequesits-pip-${TARGET_TRIPLET})
endif()
set(ENV{PYTHON_BIN_PATH} "${PYTHON3}")

# check if numpy can be loaded
vcpkg_execute_required_process(COMMAND ${PYTHON3} -c "import numpy" WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequesits-numpy-${TARGET_TRIPLET})

# tensorflow has long file names, which will not work on windows
set(ENV{TEST_TMPDIR} ${BUILDTREES_DIR}/.bzl)

set(ENV{USE_DEFAULT_PYTHON_LIB_PATH} 1)
set(ENV{TF_NEED_KAFKA} 0)
set(ENV{TF_NEED_OPENCL_SYCL} 0)
set(ENV{TF_NEED_AWS} 0)
set(ENV{TF_NEED_GCP} 0)
set(ENV{TF_NEED_HDFS} 0)
set(ENV{TF_NEED_S3} 0)
set(ENV{TF_ENABLE_XLA} 0)
set(ENV{TF_NEED_GDR} 0)
set(ENV{TF_NEED_VERBS} 0)
set(ENV{TF_NEED_OPENCL} 0)
set(ENV{TF_NEED_MPI} 0)
set(ENV{TF_NEED_TENSORRT} 0)
set(ENV{TF_NEED_NGRAPH} 0)
set(ENV{TF_NEED_IGNITE} 0)
set(ENV{TF_NEED_ROCM} 0)
set(ENV{TF_SET_ANDROID_WORKSPACE} 0)
set(ENV{TF_DOWNLOAD_CLANG} 0)
set(ENV{TF_NCCL_VERSION} 2.3)
set(ENV{NCCL_INSTALL_PATH} "")
set(ENV{CC_OPT_FLAGS} "/arch:AVX")
set(ENV{TF_NEED_CUDA} 0)
set(ENV{TF_CONFIGURE_IOS} 0)

if(VCPKG_TARGET_IS_WINDOWS)
	set(BAZEL_LIB_NAME tensorflow_cc.dll)
	set(SCRIPT_SUFFIX windows)
	set(STATIC_LINK_CMD static_link.bat)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
	set(BAZEL_LIB_NAME libtensorflow_cc.dylib)
	set(SCRIPT_SUFFIX macos)
	set(STATIC_LINK_CMD sh static_link.sh)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		set(TF_LIB_NAME "libtensorflow_cc.${TF_VERSION}.dylib")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.${TF_VERSION}.dylib")
	else()
		set(TF_LIB_NAME "libtensorflow_cc.${TF_VERSION}.a")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.${TF_VERSION}.a")
	endif()
else()
	set(BAZEL_LIB_NAME libtensorflow_cc.so)
	set(SCRIPT_SUFFIX linux)
	set(STATIC_LINK_CMD sh static_link.sh)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		set(TF_LIB_NAME "libtensorflow_cc.so.${TF_VERSION}")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.so.${TF_VERSION}")
	else()
		set(TF_LIB_NAME "libtensorflow_cc.a.${TF_VERSION}")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.a.${TF_VERSION}")
	endif()
endif()

set(N_DBG_LIB_PARTS 0)
foreach(BUILD_TYPE dbg rel)
	set(STATIC_ONLY_PATCHES "")
	set(LINUX_ONLY_PATCHES "")
	if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
		set(STATIC_ONLY_PATCHES change-macros-for-static-lib.patch)  # there is no static build option - change macros via patch and link library manually at the end
	endif()
	if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
		set(LINUX_ONLY_PATCHES fix-linux-build.patch)
	endif()
	vcpkg_from_github(
		OUT_SOURCE_PATH SOURCE_PATH
		REPO tensorflow/tensorflow
		REF "v${TF_VERSION}"
		SHA512 86aa087ea84dac1ecc1023b23a378100d41cc6778ccd20404a4b955fc67cef11b3dc08abcc5b88020124d221e6fb172b33bd5206e9c9db6bc8fbeed399917eac
		HEAD_REF master
		PATCHES
			file-exists.patch # required or otherwise it cant find python lib path on windows
			fix-build-error.patch # Fix namespace error
			fix-dbg-build-errors.patch # Fix no return statement
			fix-more-build-errors.patch # Fix no return statement
			${STATIC_ONLY_PATCHES}
			${LINUX_ONLY_PATCHES}
	)

	message(STATUS "Configuring TensorFlow (${BUILD_TYPE})")
	tensorflow_try_remove_recurse_wait(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	file(RENAME ${SOURCE_PATH} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}")

	vcpkg_execute_required_process(
		COMMAND ${PYTHON3} ${SOURCE_PATH}/configure.py --workspace "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}"
		WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
		LOGNAME config-${TARGET_TRIPLET}-${BUILD_TYPE}
	)

	if(DEFINED ENV{BAZEL_CUSTOM_CACERTS})
		file(APPEND ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/.bazelrc "startup --host_jvm_args=-Djavax.net.ssl.trustStore='$ENV{BAZEL_CUSTOM_CACERTS}'\n")
		message(STATUS "Using custom CA certificate store at: $ENV{BAZEL_CUSTOM_CACERTS}")
		if(DEFINED ENV{BAZEL_CUSTOM_CACERTS_PASSWORD})
			file(APPEND ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/.bazelrc "startup --host_jvm_args=-Djavax.net.ssl.trustStorePassword='$ENV{BAZEL_CUSTOM_CACERTS_PASSWORD}'\n")
			message(STATUS "Using supplied custom CA certificate store password.")
		endif()
	else()
		if(DEFINED ENV{HTTPS_PROXY})
			message(STATUS "You are using HTTPS_PROXY. In case you encounter bazel certificate errors, you might want to set: BAZEL_CUSTOM_CACERTS=/path/to/trust.store (and optionally BAZEL_CUSTOM_CACERTS_PASSWORD), and to enable vcpkg to actually use it: VCPKG_KEEP_ENV_VARS=BAZEL_CUSTOM_CACERTS;BAZEL_CUSTOM_CACERTS_PASSWORD")
			if(CMAKE_HOST_WIN32)
				message(STATUS "(For BAZEL_CUSTOM_CACERTS please use forward slashes instead of backslashes on Windows systems.")
			endif()
		endif()
	endif()

	message(STATUS "Warning: Building TensorFlow can take an hour or more.")
	if(BUILD_TYPE STREQUAL dbg)
		if(VCPKG_TARGET_IS_WINDOWS)
			set(BUILD_OPTS "--compilation_mode=dbg --features=fastbuild") # link with /DEBUG:FASTLINK instead of /DEBUG:FULL to avoid .pdb >4GB error
		else()
			set(BUILD_OPTS "--compilation_mode=dbg")
		endif()
	else()
		set(BUILD_OPTS "--compilation_mode=opt")
	endif()

	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		if(VCPKG_TARGET_IS_WINDOWS)
			vcpkg_execute_build_process(
				COMMAND ${BASH} --noprofile --norc -c "${BAZEL} build --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --define=no_tensorflow_py_deps=true ///tensorflow:tensorflow_cc.dll ///tensorflow:install_headers"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		else()
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --define=no_tensorflow_py_deps=true //tensorflow:${BAZEL_LIB_NAME} //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
	else()
		if(VCPKG_TARGET_IS_WINDOWS)
			if(VCPKG_CRT_LINKAGE STREQUAL static)
				if(BUILD_TYPE STREQUAL dbg)
					set(CRT_OPT "-MTd")
				else()
					set(CRT_OPT "-MT")
				endif()
			endif()
			vcpkg_execute_build_process(
				COMMAND ${BASH} --noprofile --norc -c "${BAZEL} build -s --verbose_failures ${BUILD_OPTS} --features=fully_static_link --copt=${CRT_OPT} --python_path=${PYTHON3} --define=no_tensorflow_py_deps=true ///tensorflow:tensorflow_cc.dll ///tensorflow:install_headers"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		else()
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build -s --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --define=no_tensorflow_py_deps=true //tensorflow:${BAZEL_LIB_NAME} //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
		if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_${SCRIPT_SUFFIX}.py" "${N_DBG_LIB_PARTS}"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow
				LOGNAME postbuild1-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
		vcpkg_execute_build_process(
			COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_${SCRIPT_SUFFIX}.py" "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-${BUILD_TYPE}-err.log" # for some reason stdout of bazel ends up in stderr
			WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
			LOGNAME postbuild2-${TARGET_TRIPLET}-${BUILD_TYPE}
		)
		vcpkg_execute_build_process(
			COMMAND ${STATIC_LINK_CMD}
			WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
			LOGNAME postbuild3-${TARGET_TRIPLET}-${BUILD_TYPE}
		)
	endif()

	if(BUILD_TYPE STREQUAL dbg)
		set(DIR_PREFIX "/debug")
	else()
		set(DIR_PREFIX "")
	endif()

	if(VCPKG_TARGET_IS_WINDOWS)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.dll DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
			# rename before copy because after copy the file might be locked by anti-malware scanners for some time so that renaming fails
			file(RENAME ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.dll.if.lib ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			if(BUILD_TYPE STREQUAL dbg)
				file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.pdb DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
				message(STATUS "Warning: debug information tensorflow_cc.pdb will be of limited use because only a reduced set could be produced due to the 4GB internal PDB file limit even on x64.")
			endif()
		else()
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			set(TF_LIB_SUFFIXES "")
			# library might have been split because no more than 4GB are supported even on x64 Windows
			foreach(PART_NO RANGE 2 100)
				if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc-part${PART_NO}.lib)
					file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc-part${PART_NO}.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
					set(N_DBG_LIB_PARTS ${PART_NO})
					list(APPEND TF_LIB_SUFFIXES "-part${PART_NO}")
				else()
					break()
				endif()
			endforeach()
		endif()
	else()
		file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/${TF_LIB_NAME} DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
		file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/${TF_FRAMEWORK_NAME} DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
	endif()
endforeach()

file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/tensorflow-external)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	message(STATUS "Warning: Static TensorFlow build contains several external dependancies that may cause linking conflicts (e.g. you cannot use openssl in your projects as TensorFlow contains boringssl and so on).")
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/LICENSE ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/copyright)

if(VCPKG_TARGET_IS_WINDOWS)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		file(COPY ${CMAKE_CURRENT_LIST_DIR}/tensorflow-cc-config-windows-dll.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
		file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config-windows-dll.cmake ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config.cmake)
	else()
		file(COPY ${CMAKE_CURRENT_LIST_DIR}/tensorflow-cc-config-windows-lib.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
		file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config-windows-lib.cmake ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config.cmake)
		set(ALL_PARTS "tensorflow_cc::tensorflow_cc-part1")
		foreach(part ${TF_LIB_SUFFIXES})
			file(APPEND ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config.cmake "\n\
add_library(tensorflow_cc::tensorflow_cc${part} STATIC IMPORTED)\n\
set_target_properties(tensorflow_cc::tensorflow_cc${part}\n\
	PROPERTIES\n\
	IMPORTED_LOCATION \"${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/lib/tensorflow${part}.lib\"\n\
	INTERFACE_INCLUDE_DIRECTORIES \"${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/include/tensorflow-external\"\n\
)\n\
")
			list(APPEND ALL_PARTS "tensorflow_cc::tensorflow_cc${part}")
		endforeach()
		file(APPEND ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config.cmake "\n\
add_library(tensorflow_cc::tensorflow_cc INTERFACE IMPORTED)\n\
set_property(TARGET tensorflow_cc::tensorflow_cc PROPERTY INTERFACE_LINK_LIBRARIES ${ALL_PARTS})\n\
")
	endif()
else()
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		set(TF_LINKAGE_TYPE SHARED)
	else()
		set(TF_LINKAGE_TYPE STATIC)
	endif()
	configure_file(${CMAKE_CURRENT_LIST_DIR}/tensorflow-cc-config.cmake.in ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/tensorflow-cc-config.cmake)
endif()

message(STATUS "You may want to delete ${CURRENT_BUILDTREES_DIR} and ${BUILDTREES_DIR}/.bzl to free diskspace.")
