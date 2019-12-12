#!/usr/bin/env python
__copyright__ = """
COPYRIGHT: (c)2019 Maxim Paperno; All Rights Reserved.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
"""

DESCRIPTION = """
A utility to find Doxygen-compatible .tags files in a Qt Docs installation
folder and either concatenate them all into one large .tags file (for online
linking), or copy them all to a single folder (for QHP generation with locally
linked references). This simplifies use with Doxygen's TAGFILES feature since
the tagfiles can be referenced from a constant location relative to the other
Doxygen-related assets.  
"""

HELPTEXT = """
<Qt-Docs-root> argument should point to a Qt documentation installation folder, 
for example "/usr/qt/Docs/Qt-5.12.6" or "c:\Qt\Docs\Qt-5.12.6".

If the docs root argument is not provided, then the value of environment
variables  QT_DIR and QTHOME are checked (if both are found, the former takes
precedence).  If a valid path was found, it is searched for a "Docs" subfolder
which contains  subfolders in the format of "Qt-5.#.#" (where the numbers
represent a Qt version).  The newest, or only, version subfolder found is then
used as the Qt docs root.

The list of modules to import documentation from is essentially a list of
subfolder(s) of this documentation root. Each module folder should contain an
identically named .tags file (eg. /Docs/Qt-5.12.6/qtcore/qtcore.tags).
"""

# Default module set, only import tags for ones we're very likely to need.
QTMODULES = [
  "qtcore",
  # "qtbluetooth",
  # "qtconcurrent",
  # "qtdbus",  # no tagfile
  "qtgui",
  # "qtnetwork",
  "qtprintsupport",
  # "qtqml",
  # "qtquick",
  # "qtquickcontrols",
  # "qtsvg",
  "qtwidgets",
]

# Default output path/file (only the path part is used when copying with -i opt)
OUTPUT_DEST = "tagfiles/qt.tags"

import argparse
import glob
import os
import re
import sys
from shutil import copy2

def copyFiles(modules, docsdir, destpath):
  for module in modules:
    tagfile = os.path.join(docsdir, module, module + ".tags")
    if os.path.isfile(tagfile):
      print("Copying tag file: " + tagfile)
      copy2(tagfile, destpath)
    else:
      print("Could not find "+tagfile+", skipping.")
  return 0


def concatFiles(modules, docsdir, destfile):
  # get Qt version, only for a comment in the created tags file, not vital
  qtver = os.getenv("QT_VERSION", os.path.basename(os.path.normpath(docsdir)))
  qtver = re.sub("[^\d\.]", "", qtver)
  if not qtver:
    qtver = "(unknown)"
  with open(destfile, "w", encoding="utf-8") as f:
    # write an opening header with inserted comment
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    f.write("<!-- tagfiles for module(s): %s \n"
            "     imported from Qt docs for v%s -->\n" % (modules, qtver))
    f.write('<tagfile>\n')
    for module in modules:
      tagfile = os.path.join(docsdir, module, module + ".tags")
      if not os.path.isfile(tagfile):
        print("Could not find "+tagfile+", skipping.")
        continue 
      with (open(tagfile, "r", encoding="utf-8")) as tf:
        print("Adding tag file: " + tagfile)
        f.write("\n\n<!--\n    tagfile: %s\n-->\n\n" % os.path.basename(tagfile))
        tagtext = tf.read()
        # strip opening header tags from input files
        tagtext = tagtext[re.search('<tagfile>\n', tagtext).end():]
        # strip closing tag also, but not from the last file
        if module != modules[-1]:
          tagtext = tagtext[:tagtext.rfind('</tagfile>\n')]
        f.write(tagtext)
  return 0


def main():
  parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description=DESCRIPTION, epilog=HELPTEXT)

  parser.add_argument("docsroot", nargs='?', metavar="<Qt-Docs-root>", 
    help="Qt documentation installation folder.")
  parser.add_argument("-m", nargs="*", metavar="<module>", default=QTMODULES, 
    help="Qt module(s) to import (default: %(default)s).")
  parser.add_argument("-i", default=False, action="store_true", 
    help="Copy individual files instead of concatenating.")
  parser.add_argument("-o", metavar="<filenpath>", default=OUTPUT_DEST, 
    help="Output file (default: %(default)s).")

  opts = parser.parse_args();

  if not len(opts.m):
    sys.exit("Empty modules list, nothing to import.")

  destfile = os.path.dirname(os.path.normpath(opts.o)) if opts.i else opts.o
  destpath = destfile if opts.i else os.path.dirname(destfile)
  if not destfile or not os.access(destpath, os.W_OK):
    sys.exit("Unable access output location " + destfile)
  print("Output to: " + destfile)

  docsdir = ""
  if opts.docsroot:
    docsdir = opts.docsroot
  else:
    # try to find docs folder based on QTHOME or QT_DIR env. vars
    qtdir = os.getenv("QT_DIR", os.getenv('QTHOME', ""))
    if qtdir:
      qtdir = os.path.join(qtdir, "Docs", "Qt-5*")
      dirs = list(filter(os.path.isdir, glob.glob(qtdir)))
      if len(dirs):
        dirs.sort(key = lambda x: os.path.getctime(x), reverse = True)
        docsdir = dirs[0]

  if not docsdir or not os.path.isdir(docsdir) or not os.access(docsdir, os.R_OK):
    sys.exit("Unable to determine or access Qt docs directory: " + docsdir)

  print("Using source directory: %s" % docsdir)

  if opts.i:
    # just copy individual files
    return copyFiles(opts.m, docsdir, destpath)

  # concatenate tagfiles into one
  return concatFiles(opts.m, docsdir, destfile)


if __name__ == "__main__":
  sys.exit(main())
