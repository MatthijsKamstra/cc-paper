package;

import js.Browser.*;
import js.Browser;
import js.html.*;
import model.constants.App;
import cc.model.constants.Paper;
import cc.model.constants.DPI;
import art.*;
import Sketch;
// settings
import quicksettings.QuickSettings;

class Main {
	public static var count = 0;// debug value, make sure this is zero!!!
	// settings
	var panel1:QuickSettings;
	var isLandscape = false;
	var paperW = 0; // in mm
	var paperH = 0; // in mm
	var dpi = 0;
	var paperName:String;

	public function new() {
		trace('START :: main');
		document.addEventListener("DOMContentLoaded", function(event) {
			console.log('${App.NAME} Dom ready :: build: ${App.BUILD} ');
			createQuickSettings();
			// var cc = new CC051a();
			setValues();
			setNav();
		});
	}

	function createQuickSettings() {
		// demo/basic example
		panel1 = QuickSettings.create(10, 10, "Settings", document.getElementById('settings'))

			.setGlobalChangeHandler(untyped setValues)

			.addHTML("cc-paper", "different paper sizes and resolution")
			.addDropDown('Mode', ['Portrait', 'Landscape'], function(obj) setMode(obj))

			.addDropDown('Paper size', Paper.ARR, function(obj) setPaper(obj))
			.addDropDown('DPI', DPI.ARR, function(obj) setDPI(obj))

			// .addTextArea('Quote', 'text', function(value) trace(value))
			.addTextArea('out', '', function(value) { /*trace(value)*/})

			// .addBoolean('All Caps', false, function(value) trace(value))

			.setDraggable(false)

			// .setKey('h') // use `h` to toggle menu

			.saveInLocalStorage('cc-paper');
	}

	// ____________________________________ settings ____________________________________

	function setValues() {
		trace('setValues (from settings)');
		setDPI(panel1.getValue('DPI'));
		setMode(panel1.getValue('Mode'));
		setPaper(panel1.getValue('Paper size'));
		setCanvas();
	}

	function setDPI(obj:{value:String, index:Int}) {
		// trace(obj);
		switch (obj.value) {
			case '72':
				dpi = 72;
			case '150':
				dpi = 150;
			case '300':
				dpi = 300;
			default:
				trace("case '" + obj.value + "': trace ('" + obj.value + "');");
		}
		// out('x');
	}

	function setMode(obj:{value:String, index:Int}) {
		// trace(obj);
		if (obj.value == 'Portrait') {
			isLandscape = false;
		} else {
			isLandscape = true;
		}
		// trace( 'isLandscape: ' + isLandscape );
		// out ('isLandscape: $isLandscape');
		// setCanvas();
	}

	function setPaper(obj:{value:String, index:Int}) {
		// trace(obj);

		paperName = Paper.ARR[obj.index];

		var rec = Paper.inMM(Paper.ARR[obj.index]);
		paperW = rec.width;
		paperH = rec.height;
		if (isLandscape) {
			paperH = rec.width;
			paperW = rec.height;
		}
		// trace('paperW: $paperW mm');
		// trace('paperH: $paperH mm');
		// setCanvas();
	}



	function setCanvas() {
		trace('setCanvas ${count}');
		count++;

		// setup Sketch
		var option = new SketchOption();
		option.width = Math.round(Paper.convertmm2pixel(paperW, dpi));
		option.height = Math.round(Paper.convertmm2pixel(paperH, dpi));
		option.autostart = true;
		option.padding = 10;
		option.scale = true;
		option.dpi = dpi;
		var ctx:CanvasRenderingContext2D = Sketch.create("creative_code_mck", option);

		console.group('paper settings');
		console.log('paperName: $paperName');
		console.log('dpi: $dpi');
		console.log('paperW in mm: $paperW mm');
		console.log('paperH in mm: $paperH mm');
		console.log('paperW in px: ${option.width} px');
		console.log('paperH in px: ${option.height} px');
		console.log(option);
		console.groupEnd();

		var cc = new CC051a(ctx);
	}

	function out(value:String, ?add:Bool = false) {
		if (panel1 == null)
			return;
		var str = value;
		if (add) {
			var temp = panel1.getValue('out');
			str += temp + value;
		}
		panel1.setValue('out', str);
	}

	// ____________________________________ nav ____________________________________

	function setNav() {
		document.getElementById("openNavBtn").onclick = function() {
			// trace('open');
			openNav();
		};
		document.getElementById("closeNavBtn").onclick = function() {
			// trace('close');
			closeNav();
		};
	}

	/* Set the width of the side navigation to 250px */
	function openNav() {
		document.getElementById("mySidenav").style.width = "220px";
	}

	/* Set the width of the side navigation to 0 */
	function closeNav() {
		document.getElementById("mySidenav").style.width = "0";
	}

	// ____________________________________ main ____________________________________

	static public function main() {
		var app = new Main();
	}
}