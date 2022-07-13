function(add_nano_module NAME)
  include(FetchContent)
  FetchContent_Declare(
    ${NAME}
    GIT_REPOSITORY "https://github.com/Meta-Sonic/${NAME}.git"
    GIT_TAG master
  )

  FetchContent_MakeAvailable(${NAME})
endfunction()