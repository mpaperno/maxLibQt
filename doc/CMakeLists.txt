## Generate Doxygen docs from source

set(DOC_OUTPUT_DIR ${DOC_SRC_DIR} CACHE STRING "Documentation output path.")

find_package(Doxygen)

if(DOXYGEN_FOUND)
	set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
	set(DOXYGEN_OUT "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile")

	configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

	add_custom_target(maxLibQt-doxygen
		COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT "Generating API documentation with Doxygen."
		VERBATIM )

	## clean
	if(WIN32)
		set(RM del /Q)
	else()
		set(RM rm)
	endif()
	file(TO_NATIVE_PATH "html/*.*" DOCFILES)
	add_custom_target(maxLibQt-doxygen-clean
		COMMAND ${RM} "${DOCFILES}"
		COMMAND ${CMAKE_COMMAND} -E remove_directory html/search
		WORKING_DIRECTORY ${DOC_OUTPUT_DIR}
		VERBATIM )
	#add_dependencies(maxLibQt-doxygen maxLibQt-doxygen-clean)

endif()
