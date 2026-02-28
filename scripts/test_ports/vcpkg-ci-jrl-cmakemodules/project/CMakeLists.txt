cmake_minimum_required(VERSION 3.22)

# 1. MANDATORY: Define metadata required by jrl-cmakemodules
set(PROJECT_NAME jrl-cmakemodules-test)
set(PROJECT_DESCRIPTION "Description of my project")
set(PROJECT_URL "https://github.com/user/project")

# 2. Find the jrl-cmakemodules
find_package(jrl-cmakemodules CONFIG REQUIRED)

# 3. Include the base infrastructure
include(${jrl-cmakemodules_DIR}/base.cmake)

# 4. Setup project arguments (Version, Policies, etc.)
compute_project_args(PROJECT_ARGS LANGUAGES CXX)
project(${PROJECT_NAME} ${PROJECT_ARGS})

# 5. Find sdformat
option(TEST_SDFORMAT "Test for search_for_sdformat in jrl-cmakemodules" OFF)
if (TEST_SDFORMAT)
    include(${jrl-cmakemodules_DIR}/sdformat.cmake)
    search_for_sdformat(REQUIRED)
endif ()

# 6. Find numpy
option(TEST_NUMPY "Test for search numpy from python")
if (TEST_NUMPY)
    include("${JRL_CMAKE_MODULES}/python.cmake")
    set(PYTHON_COMPONENTS Interpreter Development.Module NumPy)
    findpython(REQUIRED)
    find_numpy()
endif ()
