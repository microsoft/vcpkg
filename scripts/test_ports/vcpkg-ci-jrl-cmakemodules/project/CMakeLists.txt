cmake_minimum_required(VERSION 3.22)

set(PROJECT_NAME jrl-cmakemodules-test)

# 1. MANDATORY: Define metadata required by jrl-cmakemodules
set(PROJECT_DESCRIPTION "Description of my project")
set(PROJECT_URL "https://github.com/user/project")

# 2. Find the jrl-cmakemodules
find_package(jrl-cmakemodules CONFIG REQUIRED)

# 3. Include the base infrastructure
include(${jrl-cmakemodules_DIR}/base.cmake)

# 4. Setup project arguments (Version, Policies, etc.)
COMPUTE_PROJECT_ARGS(PROJECT_ARGS LANGUAGES CXX)
project(${PROJECT_NAME} ${PROJECT_ARGS})