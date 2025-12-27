cmake_minimum_required(VERSION 3.22)

# 1. MANDATORY: Define metadata required by jrl-cmakemodules
set(PROJECT_NAME jrl-cmakemodules-test-sdformat)
set(PROJECT_DESCRIPTION "Description of this project")
set(PROJECT_URL "https://github.com/user/project")

# 2. Find the modules
find_package(jrl-cmakemodules CONFIG REQUIRED)

# 3. Include the base infrastructure
include(${jrl-cmakemodules_DIR}/base.cmake)

# 4. Setup project arguments (Version, Policies, etc.)
COMPUTE_PROJECT_ARGS(PROJECT_ARGS LANGUAGES CXX)
project(${PROJECT_NAME} ${PROJECT_ARGS})

# 5. Find sdformat
include(${jrl-cmakemodules_DIR}/sdformat.cmake)
search_for_sdformat(REQUIRED)
