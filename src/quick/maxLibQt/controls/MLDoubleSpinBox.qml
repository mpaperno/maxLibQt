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

	Use the \p decimals property to control precision.

	The only caveat is that to style the SpinBox using Controls 2 themes (Fusion/Material/etc) you need to apply the styling to the \p spinBoxItem
	property insted of directly to MLDoubleSpinBox (which in itself is not a Control and therefore doesn't have a theme).
	For example:  `spinBoxItem.Material.accent: Material.Pink`

	Individual property documentation can be found inline.
*/

FocusScope {
	id: control
	objectName: "MLDoubleSpinBox"

	implicitWidth: spinBoxItem ? spinBoxItem.implicitWidth : 0
	implicitHeight: spinBoxItem ? spinBoxItem.implicitHeight : 0

	signal valueModified()   //! Mimic SpinBox API

	// Standard SpinBox API properties
	property double value: 0.0
	property double from: 0.0
	property double to: 100.0
	property double stepSize: Math.max(divisor, 0.0001)   //! Default step size is based on desired precision but only up to 4 decimals.
	property bool editable: true
	property bool wrap: true
	property bool wheelEnabled: !editable || (textInputItem && textInputItem.activeFocus)   //! By default wheel is enabled only if editor has active focus or item is not editable.
	property int inputMethodHints: Qt.ImhFormattedNumbersOnly
	property font font: Qt.application.font
	property var locale: Qt.locale()

	// Custom properties
	property int decimals: 2                  //! Desired precision
	property int notation: DoubleValidator.StandardNotation   //! For validator and text formatting
	property string tooltip                   //! Passed to SpinBox::ToolTip.text.
	property bool selectByMouse: true         //! Whether to allow selection of text (bound to the text editor of the spinbox control).
	property bool useLocaleFormat: true       //! Whether to format numbers according to the current locale. If false, use standard "C" format.
	property bool showGroupSeparator: true    //! Whether to format numbers with the thousands separator visible (using current locale if useLocaleFormat is true).
	property bool trimExtraZeros: true        //! Whether to remove leading zeros from whole numbers and trailing zeros from decimals.
	property int buttonRepeatDelay: 300       //! Milliseconds to delay before held +/- button repeat is activated.
	property int buttonRepeatInterval: 100    //! +/- button repeat interval while held (in milliseconds).

	// Read-only attributes
	readonly property bool acceptableInput: textInputItem && textInputItem.acceptableInput   //! Indicates if input is valid (it would be nicer if the validator would expose an "isValid" prop/method!).
	readonly property real topValue: Math.max(from, to)                                      //! The effective maximum value
	readonly property real botValue: Math.min(from, to)                                      //! The effective minimum value

	// The SpinBox item (could be replaced with a custom one)
	property Control spinBoxItem: spinBox
	// Use the "native" text editor of the SpinBox to preserve look/feel.
	property Item textInputItem: spinBoxItem ? spinBoxItem.contentItem : null

	property QtObject validator: DoubleValidator {
		id: dblValidator
		top: control.topValue
		bottom: control.botValue
		decimals: Math.max(control.decimals, 0)
		notation: control.notation
		locale: control.useLocaleFormat && control.locale ? control.locale.name : "C"
	}

	function increase() {
		stepBy(1);
	}

	function decrease() {
		stepBy(-1);
	}

	function stepBy(steps) {
		// always use current editor value in case user has changed it w/out losing focus
		setValue(textValue() + (stepSize * steps));
	}

	function setValue(newValue, noWrap)
	{
		if (!wrap || noWrap)
			newValue = Math.max(Math.min(newValue, control.topValue), control.botValue);
		else if (newValue < control.botValue)
			newValue = control.topValue;
		else if (newValue > control.topValue)
			newValue = control.botValue;

		newValue = Math.round(newValue * factor) * divisor;  // normalize

		if (value !== newValue) {
			value = newValue;
			valueModified();
			if (spinBoxItem)
				spinBoxItem.value = 0;  // reset this to prevent it from disabling the buttons or other weirdness
			//console.log(newValue.toFixed(control.decimals));
		}
	}

	function textFromValue(value, locale)
	{
		var text = "0",
				prec = Math.max(decimals, 0);
		value = Number(value);
		if (useLocaleFormat && locale) {
			text = value.toLocaleString(locale, (useStdNotation ? 'f' : 'g'), prec);
			if (!showGroupSeparator)
				text = text.replace(new RegExp(locale.groupSeparator, "g"), "");
		}
		else if (useStdNotation)
			text = value.toFixed(prec);
		else
			text = value.toExponential(prec);
		if (trimExtraZeros)
			text = text.replace(/\.0*$|(\.\d*[1-9])(0+)$|^0+(?!\.|\b)/, "$1");
		return text;
	}

	function valueFromText(text, locale)
	{
		// We don't use Number::fromLocaleString because it throws errors when the input format isn't valid, eg. thousands separator in the wrong place. D'oh.
		if (useStdNotation)
			text = text.replace(/[^\+\-\d\.]+/g, "");
		else
			text = text.replace(/[^\+\-\d\.eE]+/g, "");
		if (!text.length)
			text = "0";
		//console.log(text, parseFloat(text).toFixed(control.decimals));
		return parseFloat(text);
	}

	// internals

	readonly property real factor: Math.pow(10, Math.max(decimals, 0))  // this is a 'real' type (vs. int) to allow for > 9 decimals
	readonly property real divisor: 1.0 / factor
	readonly property bool useStdNotation: notation === DoubleValidator.StandardNotation

	function textValue() {
		return textInputItem ? valueFromText(textInputItem.text, locale) : 0
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
			textInputItem.text = textFromValue(value, locale)

		if (!wrap && spinBoxItem) {
			if (spinBoxItem.up && spinBoxItem.up.indicator)
				spinBoxItem.up.indicator.enabled = value < topValue;
			if (spinBoxItem.down && spinBoxItem.down.indicator)
				spinBoxItem.down.indicator.enabled = value > botValue;
		}
	}

	onValueChanged: updateUi()
	Component.onCompleted: updateUi()

	Connections {
		target: control.spinBoxItem.up
		onPressedChanged: control.toggleButtonPress(control.spinBoxItem.up.pressed, true)
	}

	Connections {
		target: control.spinBoxItem.down
		onPressedChanged: control.toggleButtonPress(control.spinBoxItem.down.pressed, false)
	}

	Connections {
		target: control.textInputItem
		// Checking active focus works better than onEditingFinished because the latter doesn't fire if input is invalid (nor does it fix it up automatically).
		onActiveFocusChanged: {
			if (!control.textInputItem.activeFocus)
				control.setValue(control.textValue(), /* noWrap = */ true);
		}
	}

	Binding {
		target: control.textInputItem
		property: "selectByMouse"
		value: control.selectByMouse
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

	// The spin box itself... it's really only here for its buttons and overall formatting, we ignore its actual value/etc.
	SpinBox {
		id: spinBox
		anchors.fill: parent
		enabled: control.enabled
		wrap: control.wrap
		editable: control.editable
		font: control.font
		locale: control.locale
		inputMethodHints: control.inputMethodHints
		validator: control.validator
		ToolTip.text: control.tooltip
		from: -0x7FFFFFFF
		to: 0x7FFFFFFF
	}

	// Wheel/scroll action detection area
	MouseArea {
		anchors.fill: control
		acceptedButtons: Qt.NoButton
		enabled: control.wheelEnabled
		onWheel: {
			var delta = (wheel.angleDelta.y === 0.0 ? -wheel.angleDelta.x : wheel.angleDelta.y) / 120;
			if (wheel.inverted)
				delta *= -1;
			control.stepBy(delta);
		}
	}

}
