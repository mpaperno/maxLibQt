# maxLibQt - C++ code library for the *Qt* framework.

This is a (growing) collection of somewhat random C++ classes and QML modules for use with the [Qt](http://qt.io) framework. 

They are free to use in other open source projects under the terms of the GNU Public License (GPL).  For use in
commercial or other closed-source software, you need to contact me for a license agreement.  See the LICENSE.txt file.

The target Qt version is 5.2 and up.  Some components may work with earlier versions, but not tested.

**C++ Components:**

* Core
  * `AppDebugMessageHandler` - Custom debug/message handler class to work in conjunction with *qDebug()* family of functions.
* Item Models
  * `GroupedItemsProxyModel` - allows a grouped item presentation of a flat table data model.
* Widgets
  * `ExportableTableView` - A QTableView with features to export data as plain text or HTML.
  * `ScrollableMessageBox` - A simple message box with a large scrollable area (a QTextEdit) for detailed text (including HTML formatting).
  * `TimerEdit` - A time value line editor which accepts negative and large times (> 23:59:59), suitable for a timer, etc.
  * `TreeComboBox` - A QComboBox control which works with a tree-based data model & view, allowing drill-down selection of items.

**QML Components:**

* Controls
  * `MLDoubleSpinBox` - A SpinBox control which handles floats/doubles to the desired precision. Avoids all limitations of the current QtQuick Controls (v2.0 - 2.4) SpinBox but still using the current style (Fusion/Material/etc).
  * `MLHexSpinBox` - A SpinBox control which allows editing integers in hexadeciaml format. Allows a wide range of numbers, including unsigned (32b) integers. Based on `MLDoubleSpinBox`.

***Documentation:***

Doxygen-style documentation is embedded in the code and can be generated as either part of the CMake build or manually with the
included Doxyfile (run `doxygen doc/Doxyfile` in root of this project).  Some of the source code is further documented inline (but never enough).

This documentation is also published at https://mpaperno.github.io/maxLibQt/

Project home: https://github.com/mpaperno/maxLibQt

-------------
#### Author

Maxim Paperno   
https://github.com/mpaperno/   
http://www.WorldDesign.com/contact  

Please inquire about custom C++/Qt development work.

#### Copyright, License, and Disclaimer

Copyright (c) Maxim Paperno. All rights reserved.

See LICENSE.txt file for license details.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

*Qt* is a trademark of *The Qt Company* with which neither I nor this project have any affiliation.
