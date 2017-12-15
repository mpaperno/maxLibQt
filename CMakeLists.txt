project(maxLibQt)

cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0020 NEW)
cmake_policy(SET CMP0023 OLD)
if(POLICY CMP0042)
	cmake_policy(SET CMP0042 NEW)
endif()
if(POLICY CMP0043)
	cmake_policy(SET CMP0043 NEW)
endif()
if(POLICY CMP0054)
	cmake_policy(SET CMP0054 NEW)
endif()
if(POLICY CMP0058)
	cmake_policy(SET CMP0058 NEW)  # for ninja
endif()

set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_CXX_STANDARD 11)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

set(SRC_DIR      "${PROJECT_SOURCE_DIR}/src")
set(DOC_SRC_DIR  "${PROJECT_SOURCE_DIR}/doc")

find_package(Qt5Core)
find_package(Qt5Widgets)

if(Qt5Core_FOUND)
	message(STATUS "Qt Version: ${Qt5Core_VERSION}")
else()
	message(FATAL_ERROR "Qt not found!")
endif()

add_definitions(-DQT_USE_QSTRINGBUILDER)

set(SRC_SUBDIRS
	${SRC_DIR}/core
  ${SRC_DIR}/itemmodels
  ${SRC_DIR}/widgets
)

include_directories(${SRC_SUBDIRS})

set(BUILT_LIBRARIES)  # populated by subprojects

foreach(sub_dir ${SRC_SUBDIRS})
	add_subdirectory(${sub_dir})
endforeach(sub_dir)

# maxLibQt is a "dummy" lib so that other binaries could link
# to this single one instead of the individual libs.
# The maxLibQt target cannot be built specifically.
add_library(maxLibQt INTERFACE)
target_include_directories(maxLibQt INTERFACE ${SRC_SUBDIRS})
target_link_libraries(maxLibQt INTERFACE ${BUILT_LIBRARIES})

## Doxymentation
add_subdirectory(${DOC_SRC_DIR})
