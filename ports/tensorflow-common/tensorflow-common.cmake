set(TF_VERSION 2.10.0)
set(TF_VERSION_SHORT 2.10)

find_program(BAZEL bazel PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools" REQUIRED)
get_filename_component(BAZEL_DIR "${BAZEL}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BAZEL_DIR}")
set(ENV{BAZEL_BIN_PATH} "${BAZEL_DIR}")

function(tensorflow_try_remove_recurse_wait PATH_TO_REMOVE)
	file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	if(EXISTS "${PATH_TO_REMOVE}")
		vcpkg_execute_required_process(COMMAND ${CMAKE_COMMAND} -E sleep 5 WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-sleep-${TARGET_TRIPLET})
		file(REMOVE_RECURSE ${PATH_TO_REMOVE})
	endif()
endfunction()

string(FIND "${CURRENT_BUILDTREES_DIR}" " " POS)
if(NOT POS EQUAL -1)
	message(FATAL_ERROR "Your vcpkg path contains spaces. This is not supported by the bazel build tool. Aborting.")
endif()

if(CMAKE_HOST_WIN32)
	string(FIND "$ENV{USERNAME}" " " POS)
	if(NOT POS EQUAL -1)
		message(WARNING "Your Windows username '$ENV{USERNAME}' contains spaces. Applying work-around to bazel. Be warned of possible further issues.")
	endif()

	vcpkg_find_acquire_program(NASM)

	vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash unzip patch diffutils libintl gzip coreutils
		DIRECT_PACKAGES
			# use msys2 git as in tf install instructions
			"https://mirror.msys2.org/msys/x86_64/git-2.41.0-1-x86_64.pkg.tar.zst"
			4b58c0b7d0e97b3840b96037fd67dd47c128d063e1f295015c842d29abe3274bf2df275f4996b23d7a4a2e211c63d037c80efaeacf995950a57f29a284a6e9c0
	)
	cmake_path(CONVERT "${MSYS_ROOT}" TO_NATIVE_PATH_LIST MSYS_ROOT_NATIVE)
	vcpkg_add_to_path(PREPEND "${MSYS_ROOT_NATIVE}\\usr\\bin")

	set(ENV{BAZEL_SH} "${MSYS_ROOT}/usr/bin/bash.exe")
	set(ENV{BAZEL_VC} "$ENV{VCInstallDir}")
	set(ENV{BAZEL_VC_FULL_VERSION} "$ENV{VCToolsVersion}")

	include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python-packages/x_vcpkg_get_python_packages.cmake")
	x_vcpkg_get_python_packages(
		PYTHON_VERSION 3
		PACKAGES numpy
		OUT_PYTHON_VAR PYTHON3
	)
	message(STATUS "Using Python3: ${PYTHON3}")
	cmake_path(GET PYTHON3 PARENT_PATH python_dir)
	cmake_path(CONVERT "${python_dir}" TO_NATIVE_PATH_LIST python_dir_native)
	vcpkg_add_to_path(PREPEND "${python_dir_native}")
else()
	vcpkg_find_acquire_program(GIT)
	cmake_path(GET GIT PARENT_PATH git_dir)
	vcpkg_add_to_path(PREPEND "${git_dir}")

	vcpkg_find_acquire_program(PYTHON3)

	# on macos arm64 use conda miniforge
	if (VCPKG_HOST_IS_OSX)
		EXEC_PROGRAM(uname ARGS -m OUTPUT_VARIABLE HOST_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)
		if(HOST_ARCH STREQUAL "arm64")
			message(STATUS "Using python from miniforge3 ")

			if (NOT EXISTS ${CURRENT_BUILDTREES_DIR}/miniforge3)
				vcpkg_execute_required_process(COMMAND curl -fsSLo Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh" WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-miniforge3-${TARGET_TRIPLET})
				vcpkg_execute_required_process(COMMAND bash ./Miniforge3.sh -p ${CURRENT_BUILDTREES_DIR}/miniforge3 -b WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-miniforge3-${TARGET_TRIPLET})
				SET(PYTHON3 ${CURRENT_BUILDTREES_DIR}/miniforge3/bin/python3)
			endif()
		endif()
	endif()
	vcpkg_execute_required_process(COMMAND ${PYTHON3} -m venv --symlinks "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv"  WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-venv-${TARGET_TRIPLET})
	vcpkg_add_to_path(PREPEND ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/bin)
	set(PYTHON3 ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv/bin/python3)
	set(ENV{VIRTUAL_ENV} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv)

	if(VCPKG_TARGET_IS_OSX)
		vcpkg_execute_required_process(COMMAND ${PYTHON3} -m pip install -U pip WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-pip-${TARGET_TRIPLET})
		# acceleration libs currently broken on macOS => force numpy user space reinstall without BLAS/LAPACK/ATLAS
		# remove this work-around again, i.e. default to "else" branch, once acceleration libs are fixed upstream
		set(ENV{BLAS} "None")
		set(ENV{LAPACK} "None")
		set(ENV{ATLAS} "None")
		vcpkg_execute_required_process(COMMAND ${PYTHON3} -m pip install -U --force-reinstall numpy WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequistes-pip-${TARGET_TRIPLET})
	else()
		vcpkg_execute_required_process(COMMAND ${PYTHON3} -m pip install -U pip numpy WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-pip-${TARGET_TRIPLET})
	endif()
endif()
vcpkg_execute_required_process(COMMAND ${PYTHON3} -c "import site; print(site.getusersitepackages())" WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-pypath-${TARGET_TRIPLET} OUTPUT_VARIABLE PYTHON_LIB_PATH)
set(ENV{PYTHON_BIN_PATH} "${PYTHON3}")
set(ENV{PYTHON_LIB_PATH} "${PYTHON_LIB_PATH}")

# check if numpy can be loaded
vcpkg_execute_required_process(COMMAND ${PYTHON3} -c "import numpy" WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR} LOGNAME prerequisites-numpy-${TARGET_TRIPLET})

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
set(ENV{TF_NCCL_VERSION} ${TF_VERSION_SHORT})
set(ENV{NCCL_INSTALL_PATH} "")
set(ENV{TF_NEED_CUDA} 0)
set(ENV{TF_CONFIGURE_IOS} 0)

if(VCPKG_TARGET_IS_WINDOWS)
	set(BAZEL_LIB_NAME tensorflow${TF_LIB_SUFFIX}.dll)
	set(PLATFORM_SUFFIX windows)
	set(STATIC_LINK_CMD static_link.bat)
elseif(VCPKG_TARGET_IS_OSX)
	set(BAZEL_LIB_NAME libtensorflow${TF_LIB_SUFFIX}.dylib)
	set(PLATFORM_SUFFIX macos)
	set(STATIC_LINK_CMD sh static_link.sh)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		set(TF_LIB_NAME "libtensorflow${TF_LIB_SUFFIX}.dylib")
		set(TF_LIB_NAME_SHORT "libtensorflow${TF_LIB_SUFFIX}.2.dylib")
		set(TF_LIB_NAME_FULL "libtensorflow${TF_LIB_SUFFIX}.${TF_VERSION}.dylib")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.dylib")
		set(TF_FRAMEWORK_NAME_SHORT "libtensorflow_framework.2.dylib")
		set(TF_FRAMEWORK_NAME_FULL "libtensorflow_framework.${TF_VERSION}.dylib")
	else()
		set(TF_LIB_NAME "libtensorflow${TF_LIB_SUFFIX}.a")
		set(TF_LIB_NAME_SHORT "libtensorflow${TF_LIB_SUFFIX}.2.a")
		set(TF_LIB_NAME_FULL "libtensorflow${TF_LIB_SUFFIX}.${TF_VERSION}.a")
	endif()
else()
	set(BAZEL_LIB_NAME libtensorflow${TF_LIB_SUFFIX}.so)
	set(PLATFORM_SUFFIX linux)
	set(STATIC_LINK_CMD sh static_link.sh)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		set(TF_LIB_NAME "libtensorflow${TF_LIB_SUFFIX}.so")
		set(TF_LIB_NAME_SHORT "libtensorflow${TF_LIB_SUFFIX}.so.2")
		set(TF_LIB_NAME_FULL "libtensorflow${TF_LIB_SUFFIX}.so.${TF_VERSION}")
		set(TF_FRAMEWORK_NAME "libtensorflow_framework.so")
		set(TF_FRAMEWORK_NAME_SHORT "libtensorflow_framework.so.2")
		set(TF_FRAMEWORK_NAME_FULL "libtensorflow_framework.so.${TF_VERSION}")
	else()
		set(TF_LIB_NAME "libtensorflow${TF_LIB_SUFFIX}.a")
		set(TF_LIB_NAME_SHORT "libtensorflow${TF_LIB_SUFFIX}.a.2")
		set(TF_LIB_NAME_FULL "libtensorflow${TF_LIB_SUFFIX}.a.${TF_VERSION}")
	endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  list(APPEND PORT_BUILD_CONFIGS "dbg")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  list(APPEND PORT_BUILD_CONFIGS "rel")
endif()

foreach(BUILD_TYPE IN LISTS PORT_BUILD_CONFIGS)
	# prefer repeated source extraction here for each build type over extracting once above the loop and copying because users reported issues with copying symlinks
	vcpkg_list(SET extra_patches)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
		vcpkg_list(APPEND extra_patches
			# there is no static build option - change macros via patch and link library manually at the end
			"${CMAKE_CURRENT_LIST_DIR}/change-macros-for-static-lib.patch"
		)
	endif()
	if(VCPKG_TARGET_IS_WINDOWS)
		vcpkg_list(APPEND extra_patches
			"${CMAKE_CURRENT_LIST_DIR}/fix-windows-build.patch"
			"${CMAKE_CURRENT_LIST_DIR}/def-file-filter.patch" # pylauncher mingw quirks
			"${CMAKE_CURRENT_LIST_DIR}/vcpkg-nasm.patch" # nasm x64-windows-static quirks
		)
	endif()
	vcpkg_from_github(
		OUT_SOURCE_PATH SOURCE_PATH
		REPO tensorflow/tensorflow
		REF "v${TF_VERSION}"
		SHA512 bf8a6f16393499c227fc70f27bcfb6d44ada53325aee2b217599309940f60db8ee00dd90e3d82b87d9c309f5621c404edab55e97ab8bfa09e4fc67859b9e3967
		HEAD_REF master
		PATCHES
			"${CMAKE_CURRENT_LIST_DIR}/fix-build-error.patch" # Fix namespace error
			${extra_patches}
	)
	# No interactive questions
	vcpkg_replace_string("${SOURCE_PATH}/configure.py" "answer = raw_input(question)" "answer = ''")

	message(STATUS "Configuring TensorFlow (${BUILD_TYPE})")
	tensorflow_try_remove_recurse_wait(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	file(RENAME ${SOURCE_PATH} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE})
	set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}")

	vcpkg_execute_required_process(
		COMMAND ${PYTHON3} ${SOURCE_PATH}/configure.py --workspace "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}"
		WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}
		LOGNAME config-${TARGET_TRIPLET}-${BUILD_TYPE}
		SAVE_LOG_FILES
			.tf_configure.bazelrc
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
	set(BUILD_OPTS --jobs=${VCPKG_CONCURRENCY} --config=opt)
	set(COPTS "")
	set(CXXOPTS "")
	set(LINKOPTS "")
	message(STATUS "Build Tensorflow with concurrent level: ${VCPKG_CONCURRENCY}")
	if(VCPKG_TARGET_IS_WINDOWS)
		set(PLATFORM_COMMAND WINDOWS_COMMAND)
	else()
		set(PLATFORM_COMMAND UNIX_COMMAND)
	endif()
	if(BUILD_TYPE STREQUAL "dbg")
		if(VCPKG_TARGET_IS_WINDOWS)
			set(compilation_mode "dbg")
			set(host_compilation_mode "dbg")
			# We must use dbg to get the right CRT.
			list(APPEND BUILD_OPTS --compilation_mode=dbg --host_compilation_mode=dbg)
			# overrides /DEBUG:FULL to avoid .pdb >4GB error
			#list(APPEND LINKOPTS --linkopt=/DEBUG:FASTLINK)
			#list(APPEND COPTS --copt=/Od --copt=/Z7) # as in fastbuild
			#list(APPEND LINKOPTS --linkopt=/DEBUG:FASTLINK --linkopt=/OPT:REF --linkopt=/OPT:ICF)
			#list(APPEND COPTS --host_copt=/Od --host_copt=/Z7) # as in fastbuild
			#list(APPEND LINKOPTS --host_linkopt=/DEBUG:FASTLINK --host_linkopt=/OPT:REF --host_linkopt=/OPT:ICF)
			# markers, no-op
			#list(APPEND COPTS --copt=/DVCPKG_TARGET --host_copt=/DVCPKG_HOST)
			#list(APPEND LINKOPTS --linkopt=/NODEFAULTLIB:VCPKG_TARGET.lib --host_linkopt=/NODEFAULTLIB:VCPKG_HOST.lib)
			# Align host env with target env?
			list(APPEND BUILD_OPTS
				--distinct_host_configuration=false # Until bazel 5
			)
			# Override command line to limit pdb size
			list(APPEND BUILD_OPTS --action_env "_CL_=/Od /Z7 /Gw /Gy")
			list(APPEND BUILD_OPTS --action_env "_LINK_=/DEBUG:FASTLINK /INCREMENTAL:NO")
			list(APPEND BUILD_OPTS --host_action_env "_CL_=/Od /Z7 /Gw /Gy")
			list(APPEND BUILD_OPTS --host_action_env "_LINK_=/DEBUG:FASTLINK /INCREMENTAL:NO")
		elseif(VCPKG_TARGET_IS_OSX)
			if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
				list(APPEND BUILD_OPTS --compilation_mode=opt) # debug & fastbuild build on macOS arm64 currently broken
			else()
				list(APPEND BUILD_OPTS --compilation_mode=fastbuild) # debug build on macOS x86_64 currently broken
			endif()
		else()
			list(APPEND BUILD_OPTS --compilation_mode=dbg)
		endif()

		separate_arguments(VCPKG_C_FLAGS ${PLATFORM_COMMAND} ${VCPKG_C_FLAGS})
		separate_arguments(VCPKG_C_FLAGS_DEBUG ${PLATFORM_COMMAND} ${VCPKG_C_FLAGS_DEBUG})
		foreach(OPT IN LISTS VCPKG_C_FLAGS VCPKG_C_FLAGS_DEBUG)
			list(APPEND COPTS "--copt=${OPT}")
		endforeach()
		separate_arguments(VCPKG_CXX_FLAGS ${PLATFORM_COMMAND} ${VCPKG_CXX_FLAGS})
		separate_arguments(VCPKG_CXX_FLAGS_DEBUG ${PLATFORM_COMMAND} ${VCPKG_CXX_FLAGS_DEBUG})
		foreach(OPT IN LISTS VCPKG_CXX_FLAGS VCPKG_CXX_FLAGS_DEBUG)
			list(APPEND CXXOPTS "--cxxopt=${OPT}")
		endforeach()
		separate_arguments(VCPKG_LINKER_FLAGS ${PLATFORM_COMMAND} ${VCPKG_LINKER_FLAGS})
		separate_arguments(VCPKG_LINKER_FLAGS_DEBUG ${PLATFORM_COMMAND} ${VCPKG_LINKER_FLAGS_DEBUG})
		foreach(OPT IN LISTS VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_DEBUG)
			list(APPEND LINKOPTS "--linkopt=${OPT}")
		endforeach()
	else()
		set(compilation_mode "opt")
		set(host_compilation_mode "opt")
		list(APPEND BUILD_OPTS --compilation_mode=opt)

		separate_arguments(VCPKG_C_FLAGS ${PLATFORM_COMMAND} ${VCPKG_C_FLAGS})
		separate_arguments(VCPKG_C_FLAGS_RELEASE ${PLATFORM_COMMAND} ${VCPKG_C_FLAGS_RELEASE})
		foreach(OPT IN LISTS VCPKG_C_FLAGS VCPKG_C_FLAGS_RELEASE)
			list(APPEND COPTS "--copt=${OPT}")
		endforeach()
		separate_arguments(VCPKG_CXX_FLAGS ${PLATFORM_COMMAND} ${VCPKG_CXX_FLAGS})
		separate_arguments(VCPKG_CXX_FLAGS_RELEASE ${PLATFORM_COMMAND} ${VCPKG_CXX_FLAGS_RELEASE})
		foreach(OPT IN LISTS VCPKG_CXX_FLAGS VCPKG_CXX_FLAGS_RELEASE)
			list(APPEND CXXOPTS "--cxxopt=${OPT}")
		endforeach()
		separate_arguments(VCPKG_LINKER_FLAGS ${PLATFORM_COMMAND} ${VCPKG_LINKER_FLAGS})
		separate_arguments(VCPKG_LINKER_FLAGS_RELEASE ${PLATFORM_COMMAND} ${VCPKG_LINKER_FLAGS_RELEASE})
		foreach(OPT IN LISTS VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE)
			list(APPEND LINKOPTS "--linkopt=${OPT}")
		endforeach()
	endif()

	if(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
		# tensorflow supports 10.12.6 (Sierra) or higher (64-bit)
		# but actually does not compile with < 10.14
		# https://www.tensorflow.org/install/pip#macos
		list(APPEND BUILD_OPTS --macos_minimum_os=10.14)
	endif()

	list(APPEND BUILD_OPTS
		"--python_path=${PYTHON3}"
		--define=no_tensorflow_py_deps=true
		--experimental_ui_max_stdouterr_bytes=-1
	)

	if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
		list(APPEND BUILD_OPTS --dynamic_mode=off)
	endif()

	vcpkg_list(SET SETUP_ENV)
	if(VCPKG_TARGET_IS_WINDOWS)
		vcpkg_list(SET SETUP_ENV "${CMAKE_COMMAND}" -E env "MSYS_NO_PATHCONV=1" "MSYS2_ARG_CONV_EXCL=*")
		list(APPEND BUILD_OPTS --features=fully_static_link)
		if(VCPKG_CRT_LINKAGE STREQUAL "static")
			list(APPEND BUILD_OPTS --features=static_link_msvcrt) # until bazel 5
		endif()
		# Together with def-file-filter.patch, creates workaround for a general windows build errors.
		set(vcpkg_def_file_filter "${CURRENT_BUILDTREES_DIR}/def_file_filter-${TARGET_TRIPLET}.py.log")
		file(COPY_FILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/tensorflow/tools/def_file_filter/def_file_filter.py.tpl" "${vcpkg_def_file_filter}")
		vcpkg_replace_string("${vcpkg_def_file_filter}" [[%{dumpbin_bin_path}]] [[dumpbin.exe]])
		vcpkg_replace_string("${vcpkg_def_file_filter}" [[%{undname_bin_path}]] [[undname.exe]])
		list(APPEND BUILD_OPTS --action_env "VCPKG_DEF_FILE_FILTER=${vcpkg_def_file_filter}")
		# Together with vcpkg-nasm.patch, creates workaround for a nasm build error on x64-windows-static.
		list(APPEND BUILD_OPTS --action_env "VCPKG_NASM=${NASM}")
	endif()
	# use --output_user_root to work-around too-long-path-names issue and username-with-spaces issue
	vcpkg_execute_required_process(
		COMMAND ${SETUP_ENV}
			"${BAZEL}" "--output_user_root=${CURRENT_BUILDTREES_DIR}/_bzl" --max_idle_secs=1
				build --subcommands --verbose_failures ${BUILD_OPTS} ${COPTS} ${CXXOPTS} ${LINKOPTS}
					"//tensorflow:${BAZEL_LIB_NAME}"
					"//tensorflow:install_headers"
		WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}"
		LOGNAME "build-${TARGET_TRIPLET}-${BUILD_TYPE}"
		SAVE_LOG_FILES
			# Parameter (response) files to inspect compiler flags (.obj) and linker flags (.exe)
			# x64-windows-<host_compilation_mode>-exec: used for host tool to be used during build
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/llvm/_objs/Demangle/Demangle.obj.params
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/mlir/mlir-tblgen.exe-2.params
			# x64-windows-<compilation_mode>: regular
			bazel-out/x64_windows-${compilation_mode}/bin/external/com_github_grpc_grpc/src/compiler/_objs/grpc_cpp_plugin/cpp_plugin.obj.params
			bazel-out/x64_windows-${compilation_mode}/bin/external/com_github_grpc_grpc/src/compiler/grpc_cpp_plugin.exe-2.params
			bazel-out/x64_windows-${compilation_mode}/bin/tensorflow/compiler/tf2xla/kernels/_objs/xla_ops/random_ops_util.obj.param
			bazel-out/x64_windows-${compilation_mode}/bin/tensorflow/cc/ops/random_ops_gen_cc.exe-2.params
			# bash script
			bazel-x64-windows-${compilation_mode}/external/bazel_tools/tools/genrule/genrule-setup.sh
			bazel-out/x64_windows-${compilation_mode}/bin/tensorflow/cc/array_ops_genrule.genrule_script.sh
			bazel-out/x64_windows-${compilation_mode}/bin/tensorflow/cc/random_ops_genrule.genrule_script.sh
			bazel-out/x64_windows-${compilation_mode}/bin/tensorflow/cc/training_ops_genrule.genrule_script.sh
			# ad-hoc
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/mlir/_objs/TableGen/Pass.obj.params
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/mlir/Support.lib-2.params
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/mlir/TableGen.lib-2.params
			#bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/external/llvm-project/mlir/mlir-tblgen.exe-2.params
			bazel-out/x64_windows-dbg/bin/external/llvm-project/llvm/_objs/TableGen/JSONBackend.obj.params
			bazel-out/x64_windows-dbg/bin/external/llvm-project/llvm/TableGen.lib-2.params
			bazel-out/x64_windows-dbg/bin/external/llvm-project/llvm/_objs/tblgen/TableGen.obj.params
			bazel-out/x64_windows-dbg/bin/external/llvm-project/llvm/tblgen.lib-2.params
			bazel-out/x64_windows-${host_compilation_mode}-exec-50AE0418/bin/tensorflow/compiler/mlir/xla/operator_writer_gen.exe-2.params
	)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
		set(args "${TF_VERSION}" "${TF_LIB_SUFFIX}")
		if(VCPKG_TARGET_IS_WINDOWS)
			set(args "${TF_LIB_SUFFIX}")
		endif()
		vcpkg_execute_build_process(
			COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_${PLATFORM_SUFFIX}.py" ${args}
			WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow
			LOGNAME postbuild1-${TARGET_TRIPLET}-${BUILD_TYPE}
		)
		# The following command must use the err log file because
		# bazel deliberately sends "informative logs" to stderr.
		# Cf. https://github.com/bazelbuild/bazel/issues/10496#issuecomment-664998097
		vcpkg_execute_build_process(
			COMMAND ${PYTHON3} "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_${PLATFORM_SUFFIX}.py" "${CURRENT_BUILDTREES_DIR}/build-${TARGET_TRIPLET}-${BUILD_TYPE}-err.log" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow" ${TF_VERSION} ${TF_LIB_SUFFIX}
			WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
			LOGNAME postbuild2-${TARGET_TRIPLET}-${BUILD_TYPE}
		)
		vcpkg_execute_build_process(
			COMMAND ${STATIC_LINK_CMD}
			WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-${TARGET_TRIPLET}-${BUILD_TYPE}
			LOGNAME postbuild3-${TARGET_TRIPLET}-${BUILD_TYPE}
		)
	endif()

	if(BUILD_TYPE STREQUAL "dbg")
		set(DIR_PREFIX "/debug")
	else()
		set(DIR_PREFIX "")
	endif()

	if(VCPKG_TARGET_IS_WINDOWS)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}.dll DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
			# rename before copy because after copy the file might be locked by anti-malware scanners for some time so that renaming fails
			file(RENAME ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}.dll.if.lib ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}.lib)
			file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}.lib DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib)
			if(BUILD_TYPE STREQUAL dbg)
				file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}.pdb DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/bin)
				message(STATUS "Warning: debug information tensorflow${TF_LIB_SUFFIX}.pdb will be of limited use because only a reduced set could be produced due to the 4GB internal PDB file limit even on x64.")
			endif()
		else()
			if(BUILD_TYPE STREQUAL dbg)
				set(library_parts_variable TF_LIB_PARTS_DEBUG)
			else()
				set(library_parts_variable TF_LIB_PARTS_RELEASE)
			endif()
			set(${library_parts_variable} "")

			# library might have been split because no more than 4GB are supported even on x64 Windows
			foreach(PART_NO RANGE 1 100)
				set(source "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/tensorflow${TF_LIB_SUFFIX}-part${PART_NO}.lib")
				if(EXISTS "${source}")
					file(COPY "${source}" DESTINATION "${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib")
					list(APPEND ${library_parts_variable} "tensorflow${TF_LIB_SUFFIX}-part${PART_NO}.lib")
				else()
					break()
				endif()
			endforeach()
		endif()
	else()
		file(COPY
			${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/${TF_LIB_NAME_FULL}
			DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib
		)

		# Note: these use relative links
		file(CREATE_LINK ${TF_LIB_NAME_FULL}
			${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib/${TF_LIB_NAME_SHORT}
			SYMBOLIC
		)
		file(CREATE_LINK ${TF_LIB_NAME_FULL}
			${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib/${TF_LIB_NAME}
			SYMBOLIC
		)
		if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
			file(COPY
				${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILD_TYPE}/bazel-bin/tensorflow/${TF_FRAMEWORK_NAME_FULL}
				DESTINATION ${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib
			)
			file(CREATE_LINK
				${TF_FRAMEWORK_NAME_FULL}
				${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib/${TF_FRAMEWORK_NAME_SHORT}
				SYMBOLIC
			)
			file(CREATE_LINK
				${TF_FRAMEWORK_NAME_FULL}
				${CURRENT_PACKAGES_DIR}${DIR_PREFIX}/lib/${TF_FRAMEWORK_NAME}
				SYMBOLIC
			)
		endif()
	endif()
endforeach()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	message(STATUS "Warning: Static TensorFlow build contains several external dependencies that may cause linking conflicts (for example, one cannot use both openssl and TensorFlow in the same project, since TensorFlow contains boringssl).")
	if(VCPKG_TARGET_IS_WINDOWS)
		message(STATUS "Note: For some TensorFlow features (e.g. OpRegistry), it might be necessary to tell the linker to include the whole library, i.e., link using options '/WHOLEARCHIVE:tensorflow${TF_LIB_SUFFIX}-part1.lib /WHOLEARCHIVE:tensorflow${TF_LIB_SUFFIX}-part2.lib ...'")
	else()
		message(STATUS "Note: There is no separate libtensorflow_framework.a as it got merged into libtensorflow${TF_LIB_SUFFIX}.a to avoid linking conflicts.")
		if(VCPKG_TARGET_IS_OSX)
			message(STATUS "Note: Beside TensorFlow itself, you'll need to also pass its dependancies to the linker, for example '-ltensorflow${TF_LIB_SUFFIX} -framework CoreFoundation'")
			message(STATUS "Note: For some TensorFlow features (e.g. OpRegistry), it might be necessary to tell the linker to include the whole library: '-Wl,-force_load,path/to/libtensorflow${TF_LIB_SUFFIX}.a -framework CoreFoundation -framework Security [rest of linker arguments]'")
		else()
			message(STATUS "Note: Beside TensorFlow itself, you'll need to also pass its dependancies to the linker, for example '-ltensorflow${TF_LIB_SUFFIX} -lm -ldl -lpthread'")
			message(STATUS "Note: For some TensorFlow features (e.g. OpRegistry), it might be necessary to tell the linker to include the whole library: '-Wl,--whole-archive -ltensorflow${TF_LIB_SUFFIX} -Wl,--no-whole-archive [rest of linker arguments]'")
		endif()
	endif()

	configure_file(
		${CMAKE_CURRENT_LIST_DIR}/README-${PLATFORM_SUFFIX}
		${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/README
		COPYONLY)
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/LICENSE ${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/copyright)


# NOTE: if this port ever supports VCPKG_BUILD_TYPE, use that to set these.
set(TENSORFLOW_HAS_RELEASE ON)
set(TENSORFLOW_HAS_DEBUG ON)

if(VCPKG_TARGET_IS_WINDOWS)
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		configure_file(
			${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-windows-dll.cmake.in
			${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/tensorflow${TF_PORT_SUFFIX}-config.cmake
			@ONLY)
	else()
		configure_file(
			${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-windows-lib.cmake.in
			${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/tensorflow${TF_PORT_SUFFIX}-config.cmake
			@ONLY)

		set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

		set(prefix [[${TENSORFLOW_INSTALL_PREFIX}]])

		set(libs_to_link)
		foreach(lib IN LISTS TF_LIB_PARTS_RELEASE)
			list(APPEND libs_to_link "$<$<CONFIG:Release>:${prefix}/lib/${lib}>")
		endforeach()
		foreach(lib IN LISTS TF_LIB_PARTS_DEBUG)
			list(APPEND libs_to_link "$<$<CONFIG:Debug>:${prefix}/debug/lib/${lib}>")
		endforeach()
		if(TENSORFLOW_HAS_RELEASE)
			set(TF_LIB_PARTS_DEFAULT ${TF_LIB_PARTS_RELEASE})
			set(prefix_DEFAULT "${prefix}")
		elseif(TENSORFLOW_HAS_DEBUG)
			set(TF_LIB_PARTS_DEFAULT ${TF_LIB_PARTS_DEBUG})
			set(prefix_DEFAULT "${prefix}/debug")
		endif()

		foreach(lib IN LISTS TF_LIB_PARTS_DEFAULT)
			list(APPEND libs_to_link
				"$<$<NOT:$<OR:$<CONFIG:Release>,$<CONFIG:Debug>>>:${prefix}/lib/${lib}>")
		endforeach()

		string(REPLACE ";" "\n\t\t" libs_to_link "${libs_to_link}")
		file(APPEND ${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/tensorflow${TF_PORT_SUFFIX}-config.cmake "
target_link_libraries(tensorflow${TF_LIB_SUFFIX}::tensorflow${TF_LIB_SUFFIX}
	INTERFACE
		${libs_to_link}
)"
		)
	endif()
else()
	if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
		configure_file(
			${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-shared.cmake.in
			${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/tensorflow${TF_PORT_SUFFIX}-config.cmake
			@ONLY)
	else()
		configure_file(
			${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-static.cmake.in
			${CURRENT_PACKAGES_DIR}/share/tensorflow${TF_PORT_SUFFIX}/tensorflow${TF_PORT_SUFFIX}-config.cmake
			@ONLY)
	endif()
endif()

message(STATUS "You may want to delete ${CURRENT_BUILDTREES_DIR} to free diskspace.")
message(FATAL_ERROR STOP)