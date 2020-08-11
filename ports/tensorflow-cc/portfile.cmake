message(STATUS "This TensorFlow port currently is experimental.")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
	message(FATAL_ERROR "TensorFlow does not support 32bit systems.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	vcpkg_from_github(
		OUT_SOURCE_PATH SOURCE_PATH
		REPO tensorflow/tensorflow
		REF v1.14.0
		SHA512 ac9ea5a2d1c761aaafbdc335259e29c128127b8d069ec5b206067935180490aa95e93c7e13de57f7f54ce4ba4f34a822face22b4a028f60185edb380e5cd4787
		HEAD_REF master
		PATCHES
			file-exists.patch # required or otherwise it cant find python lib path on windows
			fix-build-error.patch # Fix namespace error
			fix-dbg-build-errors.patch # Fix no return statement
	)
else()
	vcpkg_from_github(
		OUT_SOURCE_PATH SOURCE_PATH
		REPO tensorflow/tensorflow
		REF v1.14.0
		SHA512 ac9ea5a2d1c761aaafbdc335259e29c128127b8d069ec5b206067935180490aa95e93c7e13de57f7f54ce4ba4f34a822face22b4a028f60185edb380e5cd4787
		HEAD_REF master
		PATCHES
			file-exists.patch # required or otherwise it cant find python lib path on windows
			fix-build-error.patch # Fix namespace error
			fix-dbg-build-errors.patch # Fix no return statement
			change-macros-for-static-lib.patch # there is no static build option - change macros via patch and link library manually at the end
	)
endif()

vcpkg_find_acquire_program(BAZEL)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${BAZEL_DIR})
set(ENV{BAZEL_BIN_PATH} "${BAZEL}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})
set(ENV{PYTHON_BIN_PATH} "${PYTHON3}")

function(tensorflow_try_remove_recurse_wait PATH_TO_REMOVE)
	file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	if(EXISTS "${PATH_TO_REMOVE}")
		execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
		file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	endif()
endfunction()

if(CMAKE_HOST_WIN32)
	vcpkg_acquire_msys(MSYS_ROOT PACKAGES unzip patch diffutils git)
	set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
	set(ENV{BAZEL_SH} ${MSYS_ROOT}/usr/bin/bash.exe)
	set(ENV{BAZEL_VC} $ENV{VCInstallDir})
	set(ENV{BAZEL_VC_FULL_VERSION} $ENV{VCToolsVersion})
endif()

# tensorflow has long file names, which will not work on windows
set(ENV{TEST_TMPDIR} ${CURRENT_BUILDTREES_DIR}/../.bzl)

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

file(GLOB SOURCES ${SOURCE_PATH}/*)

foreach(BUILD_TYPE dbg rel)
	message(STATUS "Configuring TensorFlow (${BUILD_TYPE})")
	tensorflow_try_remove_recurse_wait(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	file(COPY ${SOURCES} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})

	vcpkg_execute_required_process(
		COMMAND ${PYTHON3} ${SOURCE_PATH}/configure.py --workspace "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}"
		WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
		LOGNAME config-${TARGET_TRIPLET}-${BUILD_TYPE}
	)

	message(STATUS "Warning: Building TensorFlow can take an hour or more.")
	if(BUILD_TYPE STREQUAL dbg)
		if(CMAKE_HOST_WIN32)
			set(BUILD_OPTS "--compilation_mode=fastbuild") # link with /DEBUG:FASTBUILD instead of /DEBUG:FULL to avoid .pdb >4GB error
		else()
			set(BUILD_OPTS "--compilation_mode=dbg")
		endif()
	else()
		set(BUILD_OPTS "--compilation_mode=opt")
	endif()

	if(CMAKE_HOST_WIN32)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			vcpkg_execute_build_process(
				COMMAND ${BASH} --noprofile --norc -c "${BAZEL} build --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true ///tensorflow:tensorflow_cc.dll ///tensorflow:install_headers"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		else()
			if(BUILD_TYPE STREQUAL dbg)
				set(CRT_OPT "-MTd")
			else()
				set(CRT_OPT "-MT")
			endif()
			vcpkg_execute_build_process(
				COMMAND ${BASH} --noprofile --norc -c "${BAZEL} build -s --verbose_failures ${BUILD_OPTS} --copt=${CRT_OPT} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true ///tensorflow:tensorflow_cc.dll ///tensorflow:install_headers"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_windows.py"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow
				LOGNAME postbuild1-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_windows.py" "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-${BUILD_TYPE}-err.log" # for some reason stdout of bazel ends up in stderr
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild2-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND static_link.bat
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild3-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
	elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true //tensorflow:libtensorflow_cc.dylib //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		else()
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build -s --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true //tensorflow:libtensorflow_cc.dylib //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_macos.py"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow
				LOGNAME postbuild1-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_macos.py" "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-${BUILD_TYPE}-err.log" # for some reason stdout of bazel ends up in stderr
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild2-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND sh static_link.sh
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild3-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
	else()
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true //tensorflow:libtensorflow_cc.so //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		else()
			vcpkg_execute_build_process(
				COMMAND ${BAZEL} build -s --verbose_failures ${BUILD_OPTS} --python_path=${PYTHON3} --incompatible_disable_deprecated_attr_params=false --define=no_tensorflow_py_deps=true //tensorflow:libtensorflow_cc.so //tensorflow:install_headers
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME build-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_linux.py"
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow
				LOGNAME postbuild1-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_linux.py" "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-${BUILD_TYPE}-err.log" # for some reason stdout of bazel ends up in stderr
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild2-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
			vcpkg_execute_build_process(
				COMMAND sh static_link.sh
				WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
				LOGNAME postbuild3-${TARGET_TRIPLET}-${BUILD_TYPE}
			)
		endif()
	endif()

	if(BUILD_TYPE STREQUAL dbg)
		set(DIR_PREFIX "/debug")
	else()
		set(DIR_PREFIX "")
	endif()

	if(CMAKE_HOST_WIN32)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.dll DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
			# rename before copy because after copy the file might be locked by anti-malware scanners for some time so that renaming fails
			file(RENAME ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.dll.if.lib ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			if(BUILD_TYPE STREQUAL dbg)
				file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.pdb DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
				message(STATUS "Warning: debug information tensorflow_cc.pdb will be of limited use because only reduced set could be produced due to 4GB internal pdb limit")
			endif()
		else()
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			# library might have been split because no more than 4GB are supported even on x64 Windows
			foreach(PART_NO RANGE 2 100)
				if(EXISTS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc-part${PART_NO}.lib)
					file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow_cc-part${PART_NO}.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
				else()
					if(BUILD_TYPE STREQUAL dbg)
						break()
					else()
						# vcpkg postbuild checks require the same number of libs for debug and release => copy dummy libs in release case
						# dummy libs must be empty so that no symbol redefinition conflicts occur
						# empty handcrafted_dummy.lib built using reverse-engineered .lib format using ArHandler.cpp from 7zip sources
						if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/tensorflow_cc-part${PART_NO}.lib)
							# misuse configure_file to achieve atomic copy+rename to avoid anti-malware scanners blocking file after copy and making rename fail
							configure_file(${CMAKE_CURRENT_LIST_DIR}/handcrafted_dummy.lib ${CURRENT_PACKAGES_DIR}/lib/tensorflow_cc-part${PART_NO}.lib COPYONLY)
						else()
							break()
						endif()
					endif()
				endif()
			endforeach()
		endif()
	elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Darwin)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_cc.1.14.0.dylib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_framework.1.14.0.dylib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
		else()
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_cc.1.14.0.a DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_framework.1.14.0.a DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
		endif()
	else()
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_cc.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_framework.so.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
		else()
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_cc.a.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/libtensorflow_framework.a.1.14.0 DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
		endif()
	endif()
endforeach()

file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-genfiles/tensorflow/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/tensorflow-external)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	message(STATUS "Warning: Static TensorFlow build contains several external dependancies that may cause linking conflicts (e.g. you cannot use openssl in your projects as TensorFlow contains boringssl and so on).")
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/LICENSE ${CURRENT_PACKAGES_DIR}/share/tensorflow-cc/copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/TensorflowCCConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc/TensorflowCCConfig.cmake ${CURRENT_PACKAGES_DIR}/share/unofficial-tensorflow-cc/unofficial-tensorflow-cc-config.cmake)
