function(nano_add_module NAME)
  include(FetchContent)
  FetchContent_Declare(
    ${NAME}
    GIT_REPOSITORY "https://github.com/Meta-Sonic/${NAME}.git"
    GIT_TAG master
  )

  FetchContent_MakeAvailable(${NAME})
endfunction()

function(nano_clang_format NAME SOURCES)
  find_program(CLANG_FORMAT clang-format REQUIRED)
  add_custom_target(${NAME}-formatting DEPENDS ${SOURCES})
  add_custom_command(TARGET ${NAME}-formatting PRE_BUILD
      COMMAND "${CLANG_FORMAT}" --Werror  --dry-run ${SOURCES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  add_dependencies(${NAME} ${NAME}-formatting)
  set_target_properties(${NAME}-formatting PROPERTIES XCODE_GENERATE_SCHEME OFF)
endfunction()
