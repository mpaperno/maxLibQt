/*
	MLDoubleSpinBox
	https://github.com/mpaperno/maxLibQt

	COPYRIGHT: (c)2018 Maxim Paperno; All Right Reserved.
	Contact: http://www.WorldDesign.com/contact

	LICENSE:

	Commercial License Usage
	Licensees holding valid commercial licenses may use this file in
	accordance with the terms contained in a written agreement between
	you and the copyright holder.

	GNU General Public License Usage
	Alternatively, this file may be used under the terms of the GNU
	General Public License as published by the Free Software Foundation,
	either version 3 of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.10
import QtQuick.Controls 2.3

/*!
	\brief MLDoubleSpinBox is a drop-in replacement for QtQuick Controls 2 SpinBox which can handle double-precision numbers up to any decimal places.
	       It supports the SpinBox API of version 2.4 (Qt 5.11) but can be used with any version of QtQuick Controls 2 (Qt v5+).

	This control also works fine for integers, with the added bonus of a much wider range of valid numbers (because doubles are used as the basis instead of ints).
	This includes being able to handle unsigned ints, something the base SpinBox can't do.

	It has mostly the same properties, methods, and signal as SpinBox, except the value/from/to/stepSize properties are doubles.
  The only exception are the \e up and \e down group, which could be accessed directly via \p spinBoxItem.
  It also has a number of other custom properties not found in the default SpinBox (see inline documentation below).

	Use the \p decimals property to control precision (default is 2).

	In addition to the regular SpinBox controls (arrow keys/wheel-scroll), it reacts to Page Up/Down keys and CTRL-scroll for page-sized steps (\sa pageSteps property).

	Individual property documentation can be found inline.
*/

Control {
	id: control
	objectName: "MLDoubleSpinBox"

	// Standard SpinBox API properties (v2.4)
	property double value: 0.0
	property double from: 0.0
	property double to: 100.0
	property double stepSize: 1.0
	property bool editable: true
	property bool wrap: true
	property int inputMethodHints: Qt.ImhFormattedNumbersOnly
	readonly property string displayText: textFromValue(value)
	readonly property bool inputMethodComposing: textInputItem ? textInputItem.inputMethodComposing : false

	// Custom properties
	property int decimals: 2                  //! Desired precision
	property int notation: DoubleValidator.StandardNotation   //! For validator and text formatting
	property string inputMask                 //! Input mask for the text edit control (\sa TextInput::inputMask).
	property bool selectByMouse: true         //! Whether to allow selection of text (bound to the text editor of the spinbox control).
	property bool useLocaleFormat: true       //! Whether to format numbers according to the current locale. If false, use standard "C" format.
	property bool showGroupSeparator: true    //! Whether to format numbers with the thousands separator visible (using current locale if useLocaleFormat is true).
	property bool trimExtraZeros: true        //! Whether to remove trailing zeros from decimals.
	property int pageSteps: 10                //! How many steps in a "page" step (PAGE UP/DOWN keys or CTRL-Wheel).
	property int buttonRepeatDelay: 300       //! Milliseconds to delay before held +/- button repeat is activated.
	property int buttonRepeatInterval: 100    //! +/- button repeat interval while held (in milliseconds).

	readonly property bool acceptableInput: textInputItem && textInputItem.acceptableInput   //! Indicates if input is valid (it would be nicer if the validator would expose an "isValid" prop/method!).
	readonly property real topValue: Math.max(from, to)                                      //! The effective maximum value
	readonly property real botValue: Math.min(from, to)                                      //! The effective minimum value

	//! The SpinBox item. To use a custom one, replace the \p contentItem with a class derived from Controls 2.x SpinBox.
	//! Or use any other \p contentItem (or even \e null) and (optionally) set the \p textInputItem to some \e Item with a \p text property for a custom display.
	readonly property SpinBox spinBoxItem: contentItem
	//! Use the "native" text editor of the SpinBox to preserve look/feel. If you use a custom SpinBox, you may need to set this property also. If defined, it must have a \e text property.
	property Item textInputItem: spinBoxItem ? spinBoxItem.contentItem : null

	property QtObject validator: DoubleValidator {
		id: dblValidator
		top: control.topValue
		bottom: control.botValue
		decimals: Math.max(control.decimals, 0)
		notation: control.notation
		locale: control.useLocaleFormat ? control.locale.name : "C"
	}

	// signals

	signal valueModified()   //! Mimic SpinBox API (interactive change only, NOT emitted if \e value property is set directly).

	// QtQuick Control properties

	wheelEnabled: !editable || (textInputItem && textInputItem.activeFocus)   //! By default wheel is enabled only if editor has active focus or item is not editable.

	// The spin box itself... it's really only here for its buttons and overall formatting, we ignore its actual value/etc.
	contentItem: SpinBox {
		width: control.availableWidth
		height: control.availableHeight
		editable: control.editable
		inputMethodHints: control.inputMethodHints
		validator: control.validator
		from: -0x7FFFFFFF; to: 0x7FFFFFFF;  // prevent interference with our real from/to values
		// wrap peroperty is set below as a Binding in case SpinBox vesion is < 2.3 (Qt 5.10).
	}

	// public function API

	function increase() {
		stepBy(1);
	}

	function decrease() {
		stepBy(-1);
	}

	//! Adjust value by number of \p steps. (Each step size is determined by the spin box stepSize property.)
	//! \param noWrap (optional) If true will prevent wrapping even if the spin box \e wrap property is true. Default is false.
	function stepBy(steps, noWrap) {
		// always use current editor value in case user has changed it w/out losing focus
		setValue(textValue() + (stepSize * steps), noWrap);
	}

	//! Set the spin box value to \p newValue. This is generally preferable to setting the \e value spin box property directly, but not required.
	//! \param noWrap (optional) If true will prevent wrapping even if the spin box \e wrap property is true. Default is false.
	//! \param notModified (optional) If true will prevent the \e valueModified() signal from being emitted. Default is false.
	//! \returns bool True if value was updated (that is, it did not equal the old value), false otherwise.
	function setValue(newValue, noWrap, notModified)
	{
		if (!wrap || noWrap)
			newValue = Math.max(Math.min(newValue, control.topValue), control.botValue);
		else if (newValue < control.botValue)
			newValue = control.topValue;
		else if (newValue > control.topValue)
			newValue = control.botValue;

		newValue = Number(newValue.toFixed(Math.max(decimals, 0)));  // round

		if (value !== newValue) {
			isValidated = true;
			value = newValue;
			isValidated = false;
			if (!notModified)
				valueModified();
			if (spinBoxItem)
				spinBoxItem.value = 0;  // reset this to prevent it from disabling the buttons or other weirdness
			//console.log(newValue.toFixed(control.decimals));
			return true;
		}
		return false;
	}

	//! Reimplimented from SpinBox
	function textFromValue(value, locale)
	{
		var text = "0",
				prec = Math.max(decimals, 0),
				useStd = (notation === DoubleValidator.StandardNotation);
		value = Number(value);

		if (useLocaleFormat) {
			if (!locale)
				locale = control.locale;
			text = value.toLocaleString(locale, (useStd ? 'f' : 'g'), prec);
			if (!showGroupSeparator)
				text = text.replace(new RegExp("\\" + locale.groupSeparator, "g"), "");
		}
		else if (useStd) {
			text = value.toFixed(prec);
		}
		else {
			text = value.toExponential(prec);
		}
		if (trimExtraZeros) {
			var pt = locale ? locale.decimalPoint : ".";
			var re = "\\" + pt + "0*$|(\\" + pt + "\\d*[1-9])(0+)$";
			text = text.replace(new RegExp(re), "$1");
		}

		return text;
	}

	//! Reimplimented from SpinBox
	function valueFromText(text, locale)
	{
		// We don't use Number::fromLocaleString because it throws errors when the input format isn't valid, eg. thousands separator in the wrong place. D'oh.
		text = String(text);
		if (useLocaleFormat && !locale)
			locale = control.locale;
		var re = "[^\\+\\-\\d\\" + (useLocaleFormat ? locale.decimalPoint : ".");
		if (notation !== DoubleValidator.StandardNotation)
			re = re + "eE";
		re = re + "]+";
		text = text.replace(new RegExp(re, "g"), "");
		if (!text.length)
			text = "0";
		//console.log(text, parseFloat(text).toFixed(control.decimals));
		return parseFloat(text);
	}

	// internals

	property bool isValidated: false

	//! Get numeric value from current text
	function textValue() {
		return textInputItem ? valueFromText(textInputItem.text, locale) : 0;
	}

	//! Set the display text directly, ** without updating the numeric \p value property **.
	function setTextValue(text, locale) {
		if (textInputItem)
			textInputItem.text = textFromValue(valueFromText(text, locale), locale);
	}

	//! Update the current value and/or formatting of the displayed text. In mnost cases one would use \e setValue() .
	function updateValueFromText() {
		var val = textValue();
		if (!setValue(val, true))
			setTextValue(val);  // make sure the text is formatted anyway
	}

	function handleKeyEvent(event) {
		var steps = 0;
		if (event.key === Qt.Key_Up)
			steps = 1;
		else if (event.key === Qt.Key_Down)
			steps = -1;
		else if (event.key === Qt.Key_PageUp)
			steps = control.pageSteps;
		else if (event.key === Qt.Key_PageDown)
			steps = -control.pageSteps;
		else if (event.key !== Qt.Key_Enter && event.key !== Qt.Key_Return)
			return;

		event.accepted = true;

		if (steps)
			stepBy(steps);
		else
			updateValueFromText();
	}

	function toggleButtonPress(press, increment)
	{
		if (!press) {
			btnRepeatTimer.stop();
			return;
		}

		if (increment)
			increase();
		else
			decrease();
		btnRepeatTimer.increment = increment;
		btnRepeatTimer.start();
	}

	function updateUi() {
		if (textInputItem)
			textInputItem.text = textFromValue(value, locale);

		if (!wrap && spinBoxItem) {
			if (spinBoxItem.up && spinBoxItem.up.indicator)
				spinBoxItem.up.indicator.enabled = value < topValue;
			if (spinBoxItem.down && spinBoxItem.down.indicator)
				spinBoxItem.down.indicator.enabled = value > botValue;
		}
	}

	onValueChanged: {
		if (!isValidated)
			setValue(value, true, true);
		updateUi();
	}

	// We need to override spin box arrow key events to distinguish from +/- button presses, otherwise we get double repeats.
	onSpinBoxItemChanged: {
		if (spinBoxItem)
			spinBoxItem.Keys.forwardTo = [control];
	}

	Component.onCompleted: updateUi()
	Keys.onPressed: handleKeyEvent(event)

	Connections {
		target: control.spinBoxItem ? control.spinBoxItem.up : null
		onPressedChanged: control.toggleButtonPress(control.spinBoxItem.up.pressed, true)
	}

	Connections {
		target: control.spinBoxItem ? control.spinBoxItem.down : null
		onPressedChanged: control.toggleButtonPress(control.spinBoxItem.down.pressed, false)
	}

	Connections {
		target: control.textInputItem
		// Checking active focus works better than onEditingFinished because the latter doesn't fire if input is invalid (nor does it fix it up automatically).
		onActiveFocusChanged: {
			if (!control.textInputItem.activeFocus)
				control.updateValueFromText();
		}
	}

	// We use a binding here just in case the resident SpinBox is older than v2.3
	Binding {
		target: control.spinBoxItem
		when: control.spinBoxItem && typeof control.spinBoxItem.wrap !== "undefined"
		property: "wrap"
		value: control.wrap
	}

	Binding {
		target: control.textInputItem
		property: "selectByMouse"
		value: control.selectByMouse
	}

	Binding {
		target: control.textInputItem
		property: "inputMask"
		value: control.inputMask
	}

	// Timer for firing the +/- button repeat events while they're held down.
	Timer {
		id: btnRepeatTimer
		property bool delay: true
		property bool increment: true
		interval: delay ? control.buttonRepeatDelay : control.buttonRepeatInterval
		repeat: true
		onRunningChanged: delay = true
		onTriggered: {
			if (delay)
				delay = false;
			else if (increment)
				control.increase();
			else
				control.decrease();
		}
	}

	// Wheel/scroll action detection area
	MouseArea {
		anchors.fill: control
		z: control.contentItem.z + 1
		acceptedButtons: Qt.NoButton
		enabled: control.wheelEnabled
		onWheel: {
			var delta = (wheel.angleDelta.y === 0.0 ? -wheel.angleDelta.x : wheel.angleDelta.y) / 120;
			if (wheel.inverted)
				delta *= -1;
			if (wheel.modifiers & Qt.ControlModifier)
				delta *= control.pageSteps;
			control.stepBy(delta);
		}
	}

}
