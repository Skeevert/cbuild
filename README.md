# cbuild
Utility that allows building CMake + make projects directly from the source directory without polluting it with build artifacts.

It creates "builds" directory in user's home, and for each built project creates it's own subdirectory, from where it calls cmake and make.
