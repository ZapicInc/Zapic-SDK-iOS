# Runs clang-format on all code files
find ../Zapic/**/*.[chm] | xargs clang-format -i -style=file

# Regex to remove Xcode header comments
# TODO: Add this to the script
# //\n//.+\n//.+\n//\n//.+\n//..Copyright.+$\n//\n\n
