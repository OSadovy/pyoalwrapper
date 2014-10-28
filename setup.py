import os
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

OALWRAPPER_PATH = r'd:\develop\OALWrapper'
OPENAL_PATH = r'd:\develop\openal-soft-1.16.0\release'
SDL2_PATH = r'd:\develop\sdl\lib\Release'
OGG_PATH = r'd:\develop\caudio\DependenciesSource\libogg-1.2.2\Release'
VORBIS_PATH = r'd:\develop\caudio\DependenciesSource\libvorbis-1.3.2\Release'
AUTOWRAP_PATH = r'c:\python27\lib\site-packages\autowrap\data_files'
j = os.path.join

oalwrapper_ext = Extension("pyoalwrapper", ["pyoalwrapper.pyx"],
include_dirs  = [j(OALWRAPPER_PATH, 'include'), j(OPENAL_PATH, 'include'), AUTOWRAP_PATH],
libraries = ['OALWrapper', 'openal32', 'sdl2', 'ogg', 'vorbis', 'Shell32'],
library_dirs =[j(OALWRAPPER_PATH, 'Release'), j(OPENAL_PATH, 'lib'), SDL2_PATH, OGG_PATH, VORBIS_PATH],
language="c++",
extra_compile_args=['/EHsc']
)

setup(ext_modules = cythonize(oalwrapper_ext, include_path=['.', AUTOWRAP_PATH]))