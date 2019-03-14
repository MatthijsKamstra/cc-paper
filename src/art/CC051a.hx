package art;

import js.Browser.*;
import cc.model.constants.Paper;
import cc.model.constants.DPI;

@:enum
abstract PatternType(String) {
	var DOTS = 'Dot grid';
	var LINES = 'Lines pattern';
	var HABBIT = 'Habbit tracker';
	var CHALLANGE = '100 days challange';
	var ISO = 'Isometric';
	var SQUARES = 'Squares';
	var POCKETBOOK = 'Pocket book';
	var SOCIAL = 'Social media plan';
}

// @:enum
// abstract GridInMM(String) {
//   var DOTS = 'Dot grid';
//   var LINES = 'Lines pattern';
//   var HABBIT = 'Habbit tracker';
//   var CHALLANGE = '100 days challange';
// }

/**
 * short description what this does
 */
class CC051a extends SketchBase {
	var shapeArray:Array<Circle> = [];
	var grid:GridUtil = new GridUtil();
	// sizes
	var _radius = 1;
	var _cellsize = 150;
	// colors
	var _color0:RGB = null;
	var _color1:RGB = null;
	var _color2:RGB = null;
	var _color3:RGB = null;
	var _color4:RGB = null;
	// font
	var isFondEmbedded = false;
	// settings
	var panel1:QuickSettings;
	var _grid:Float = 5; // grid in mm
	var _color:Int = 0xffffff;
	var _pattern:PatternType;

	// var PATTERN_DOTS = 'dots';
	// var PATTERN_LINES = 'lines';
	// var PATTERN_HABBIT = 'habbit';
	// var PATTERN_100 = '100';

	public function new(?ctx:CanvasRenderingContext2D) {
		super(ctx);

		createQuickSettings();
		setValues();

		var font = new FontFace('Miso', 'url(assets/font/miso/Miso.ttf)', {
			style: 'normal',
			weight: '400',
		});
		var font2 = new FontFace('Gunplay', 'url(assets/font/gunplay/Gunplay-Regular.woff2)', {
			style: 'normal',
			weight: '400',
		});
		document.fonts.add(font);
		document.fonts.add(font2);
		font.load();
		font.loaded.then(function(fontface) {
			trace(fontface.family);
			isFondEmbedded = true;
			drawShape();
		});
		font2.load();
		font2.loaded.then(function(fontface) {
			trace(fontface.family);
			isFondEmbedded = true;
			drawShape();
		});
	}

	// ____________________________________ settings ____________________________________

	function createQuickSettings() {
		// [mck] some situations there is a double quicksettings ...  but difficult to see, no id are used
		// var arr = document.getElementsByClassName('qs_main');
		// for (i in 0...arr.length){
		// 	var _arr = arr[i];
		// 	_arr.parentElement
		// }

		// demo/basic example
		panel1 = QuickSettings.create(10, 10, "Settings").setGlobalChangeHandler(untyped drawShape).addHTML("cc-paper", "different paper sizes and resolution")

			.addColor('Color', '#ffffff', function(value) trace(value))

			.addRange('RGB gray', 0,255,100, 1, function(value) setGrayRGB(value))


			.addDropDown('Dot color', ["none", 'Black', 'Gray', "Blue", "Red"], function(obj) setColor(obj))

			.addDropDown('Grid', ['10mm', '7mm', '5mm', '3.5mm'], function(obj) setGrid(obj))
			.addDropDown('Pattern',[
				PatternType.DOTS,
				PatternType.LINES,
				PatternType.HABBIT,
				PatternType.CHALLANGE,
				PatternType.SQUARES,
				PatternType.ISO,
				PatternType.POCKETBOOK,
				PatternType.SOCIAL,
				], function(obj)setPattern(obj))

				// .addDropDown('DPI', DPI.ARR, function(obj) setDPI(obj))

				// .addTextArea('Quote', 'text', function(value) trace(value))
				// .addTextArea('out', '', function(value) {/*trace(value)*/} ) // .addBoolean('All Caps', false, function(value) trace(value))

				// .setDraggable(false)
				// .setKey('h') // use `h` to toggle menu

			.saveInLocalStorage('cc-papersss');

		// panel1.setPosition (w-200-10, 10);
		panel1.setPosition(10, 100);
	}

	function setGrayRGB(value:Int){
		var rgb : RGB = {
			r: value, g:value, b:value
		}
		trace(value);
		var hex = rgbToHex(value, value, value);
		trace(hex);
		trace(Std.parseInt('0x$hex'));

		if(panel1 != null) {
			panel1.setValue('Color', '#${hex}');
			panel1.setValue('Dot color', 0);
		}
		_color = Std.parseInt('0x'+hex);
	}

	function setGrid(obj:{value:String, index:Int}) {
		// trace(obj);
		switch (obj.value) {
			case '10mm':
				_grid = 10;
			case '7mm':
				_grid = 7;
			case '5mm':
				_grid = 5;
			case '3.5mm':
				_grid = 3.5;
			default:
				trace("case '" + obj.value + "': trace ('" + obj.value + "');");
		}
		// out('x');
		createGrid();
	}

	function setColor(obj:{value:String, index:Int}) {
		// trace(obj);
		switch (obj.value) {
			case 'Gray':
				_color = 0xc0c0c0;
			case 'Black':
				_color = 0x000000;
			case 'Blue':
				_color = 0xBBD6F1;
			case 'Red':
				_color = 0xDFC5C8;
			case 'none':
				_color = 0xFFFFFF;
			default:
				trace("case '" + obj.value + "': trace ('" + obj.value + "');");
		}
		// out('x');
	}

	function setPattern(obj:{value:PatternType, index:Int}) {
		_pattern = obj.value;
	}

	function setValues() {
		trace('setValues (from settings)');
		setPattern(panel1.getValue('Pattern'));
		setColor(panel1.getValue('Dot color'));
		setGrid(panel1.getValue('Grid'));
		drawShape();
	}

	// ____________________________________ create ____________________________________

	function createShape(i:Int, ?point:Point) {
		var shape:Circle = {
			_id: '$i',
			_type: 'circle',
			x: point.x,
			y: point.y,
			radius: _radius,
		}
		// onAnimateHandler(shape);
		return shape;
	}

	function createGrid() {
		_cellsize = scaling(Paper.mm2pixel(_grid));
		_radius = scaling(1);

		// grid.setDimension(w*2.1, h*2.1);
		// grid.setNumbered(3,3);
		grid.setCellSize(_cellsize);
		grid.setIsCenterPoint(true);

		shapeArray = [];
		for (i in 0...grid.array.length) {
			shapeArray.push(createShape(i, grid.array[i]));
		}
	}

	function drawDotsPattern() {
		// set default values
		ctx.fillColourRGB(toRGB(_color));
		// ctx.strokeColourRGB(toRGB(_color));
		// ctx.strokeWeight(scaling(Paper.mm2pixel(1)));
		// ctx.strokeWeight(1);
		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
			ctx.circleFill(sh.x, sh.y, sh.radius);
		}
	}

	function drawHabbitPattern() {
		var total = 31;

		ctx.fillColourRGB(WHITE);
		ctx.strokeColourRGB(toRGB(_color));
		ctx.fillColourRGB(BLACK);
		ctx.strokeWeight(scaling(1));
		// ctx.strokeWeight(scaling(Paper.mm2pixel(1)));

		var size = scaling(Paper.mm2pixel(_grid));

		var padding = scaling(10);
		var monthBarW = size * total;

		var xstart = w - monthBarW - (padding);
		var ystart = 100;

		for (i in 0...total) {
			var x = xstart + (size * i);
			var y = ystart;
			ctx.centreStrokeRect(x, y, size, size);
			FontUtil.create(ctx, Std.string(i + 1))
				.font('Miso')
				.centerAlign()
				.middleBaseline()
				.pos(x, y)
				.size(scaling(10))
				.draw();
		}

		var barL = w - monthBarW - (padding * 3);
		xstart = padding;
		ctx.leftStrokeRect(xstart, ystart - (size / 2), barL, size);
		FontUtil.create(ctx, 'Habbit')
			.font('Miso')
			.centerAlign()
			.middleBaseline()
			.pos(xstart, ystart)
			.size(scaling(10))
			.draw();

		// ctx.fillColourRGB(toRGB(_color));
		// for (i in 0...shapeArray.length) {
		// 	var sh = shapeArray[i];
		// 	ctx.circleFill(sh.x, sh.y, sh.radius);
		// }
	}

	function drawLinesPattern() {
		ctx.fillColourRGB(toRGB(_color));
		ctx.strokeColourRGB(toRGB(_color));
		ctx.strokeWeight(scaling(1));
		// ctx.strokeWeight(1);
		var offset = scaling(Paper.mm2pixel(_grid));
		var total = Math.ceil(h / offset);
		for (i in 0...total) {
			ctx.line(0, i * offset, w, i * offset);
		}
	}

	function draw100HabbitPattern() {
		trace('100 day challenge');

		_cellsize = scaling(Paper.mm2pixel(_grid));
		_radius = scaling(20);

		var padding = scaling(50);

		var grid:GridUtil = new GridUtil();
		grid.setNumbered(10, 10);
		grid.setDimension(w - (2 * padding), h - (4 * padding));
		grid.setPosition(padding, scaling(150));
		// grid.setCellSize(_cellsize);
		grid.setIsCenterPoint(true);

		shapeArray = [];
		for (i in 0...grid.array.length) {
			shapeArray.push(createShape(i, grid.array[i]));
		}

		ctx.fillColourRGB(toRGB(_color));
		ctx.strokeColourRGB(toRGB(_color));
		// ctx.strokeColourRGB(BLACK);
		// trace(scaling(1));
		ctx.strokeWeight(scaling(1));
		// ctx.strokeWeight(8);
		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
			ctx.circleStroke(sh.x, sh.y, _radius);
			// ctx.fillColourRGB(toRGB(_color));
			FontUtil.create(ctx, Std.string(i + 1))
				.font('Miso')
				.centerAlign()
				.middleBaseline()
				.pos(sh.x, sh.y + 1)
				.size(scaling(25))
				.draw();
		}

		ctx.fillColourRGB(BLACK);
		FontUtil.create(ctx, '100 Day challange'.toUpperCase())
			.font('Gunplay')
			.leftAlign()
			.middleBaseline()
			.pos(scaling(50), scaling(80))
			.size(scaling(50))
			.draw();

		FontUtil.create(ctx, 'Challange:'.toUpperCase())
			.font('Gunplay')
			.leftAlign()
			.middleBaseline()
			.pos(scaling(50), scaling(120))
			.size(scaling(30))
			.draw();
	}

	function drawIsoPattern(){
		trace('WIP iso pattern');
	}

	var weekNL = ['ma', 'di', 'wo', 'do' , 'vr', 'za', 'zo'];

	function drawSocialPattern (){

		ctx.clearRect(0,0,w,h);
		trace('WIP social pattern');
		// _cellsize = scaling(Paper.mm2pixel(_grid));
		// _radius = scaling(20);

		var padding = scaling(50);

		// trace(7);
		// trace(Math.ceil(31/7));


		var grid:GridUtil = new GridUtil();
		grid.setDebug(isDebug);
		grid.setNumbered(7, Math.ceil(31/7));
		// grid.setDimension(w - (padding) , h - (padding));
		grid.setDimension(w - (2 * padding), h - (4 * padding));
		// grid.setPosition(padding, scaling(150));
		// grid.setCellSize(_cellsize);
		grid.setIsCenterPoint(true);

		// if (isDebug) {
		// 	ShapeUtil.gridRegisters(ctx, grid);
		// }

		var sh = grid.array[0];
		FontUtil.create(ctx, 'Social media plan'.toUpperCase())
			.font('Miso')
			.leftAlign()
			.color(BLACK)
			.middleBaseline()
			.pos(sh.x - grid.cellWidth/2,sh.y - grid.cellHeight*1)
			.size(scaling(30))
			.draw();

		for (i in 0...weekNL.length){
			var _weekNL = weekNL[i];
			var sh = grid.array[i];
			FontUtil.create(ctx, _weekNL.toUpperCase())
				.font('Miso')
				.centerAlign()
				.color(BLACK)
				.middleBaseline()
				.pos(sh.x, sh.y - grid.cellHeight*.66)
				.size(scaling(20))
				.draw();
		}

		for (i in 0...grid.array.length){
			var sh = grid.array[i];
			ctx.strokeWeight(scaling(1));
			ctx.centreStrokeRect(sh.x, sh.y, grid.cellWidth,grid.cellHeight);
			// ctx.circleStroke(sh.x, sh.y, grid.cee);
			// FontUtil.create(ctx, '${i+1}')
			// 	.font('Miso')
			// 	.centerAlign()
			// 	.color(BLACK)
			// 	.middleBaseline()
			// 	.pos(sh.x + scaling(0), sh.y + scaling(0))
			// 	.size(scaling(12))
			// 	.draw();

			// title
			if (i >= art.SocialMediaCalendar.arr.length) continue;
			// var title = art.SocialMediaCalendar.arr[i].title.split(' ').join('\n\r');
			var title = art.SocialMediaCalendar.arr[i].title;
			// split text up into string/lines
			var lines:Array<String> = TextUtil.getLines(ctx, title, grid.cellWidth-scaling(50));
			// trace(lines);
			var startY = 0.0;
			for (j in 0...lines.length) {
				var line = lines[j];
				var ypos = sh.y - (grid.cellHeight*.33) + (j*scaling(12));
				FontUtil.create(ctx, line)
					.font('Miso')
					.centerAlign()
					.color(BLACK)
					.middleBaseline()
					.pos(sh.x + scaling(0), ypos)
					.size(scaling(12))
					.draw();
				startY = ypos;
			}

			// descriptoin
			var description = art.SocialMediaCalendar.arr[i].description;
			// split text up into string/lines
			var lines:Array<String> = TextUtil.getLines(ctx, description, grid.cellWidth-scaling(50));
			// trace(lines);
			for (j in 0...lines.length) {
				var line = lines[j];
				var ypos = startY + ((j+2)*scaling(10));
				FontUtil.create(ctx, line)
					.font('Miso')
					.centerAlign()
					.color(GRAY)
					.middleBaseline()
					.pos(sh.x + scaling(0), ypos)
					.size(scaling(10))
					.draw();
			}
		}

	}


	function drawPocketBookPattern(){
		trace('WIP drawPocketBookPattern ');


		createGrid();

		// set default values
		ctx.fillColourRGB(toRGB(_color));
		// ctx.strokeColourRGB(toRGB(_color));
		// ctx.strokeWeight(scaling(Paper.mm2pixel(1)));
		// ctx.strokeWeight(1);
		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
			ctx.circleFill(sh.x, sh.y, sh.radius);
		}


		ctx.strokeWeight(scaling(1));

		// folding line
		// ctx.strokeColourRGB(toRGB(_color));
		ctx.strokeColourRGB(BLACK);
		ctx.setLineDash([scaling(10)]);
		ctx.line(w/2, 0, w/2, h); // |
		ctx.line(0, h/4, w, h/4); // -
		ctx.line(0, h/4*3, w, h/4*3); // -
		ctx.line(0, h/2, w, h/2); // -
		// cutting line
		ctx.strokeColourRGB(BLACK);
		ctx.setLineDash([0]);
		ctx.line(w/2, h/4*1, w/2, h/4*3); // |

		FontUtil.create(ctx, '1')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateRight()
			.pos(w2-scaling(10), h/8*1)
			.draw();
		FontUtil.create(ctx, '2')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateRight()
			.pos(w2-scaling(10), h/8*3)
			.draw();
		FontUtil.create(ctx, '3')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateRight()
			.pos(w2-scaling(10), h/8*5)
			.draw();
		FontUtil.create(ctx, '4')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateRight()
			.pos(w2-scaling(10), h/8*7)
			.draw();
		FontUtil.create(ctx, '5')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateLeft()
			.pos(w2+scaling(10), h/8*7)
			.draw();
		FontUtil.create(ctx, '6')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateLeft()
			.pos(w2+scaling(10), h/8*5)
			.draw();
		FontUtil.create(ctx, 'back')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateLeft()
			.pos(w2+scaling(10), h/8*3)
			.draw();
		FontUtil.create(ctx, 'front')
			.color(GRAY)
			.centerAlign()
			.middleBaseline()
			.size(scaling(12))
			.rotateLeft()
			.pos(w2+scaling(10), h/8*1)
			.draw();

	}
	function drawSquaresPattern(){
		trace('square');

		_cellsize = scaling(Paper.mm2pixel(_grid));
		// _radius = scaling(1);

		grid.setDimension(w*2.1, h*2.1);
		// grid.setNumbered(3,3);
		grid.setPosition(0,0);
		grid.setCellSize(_cellsize);
		// grid.setIsCenterPoint(true);

		shapeArray = [];
		for (i in 0...grid.array.length) {
			shapeArray.push(createShape(i, grid.array[i]));
		}

		// ctx.fillColourRGB(BLACK);
		ctx.strokeColourRGB(toRGB(_color));
		ctx.strokeWeight(scaling(1));
		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
			ctx.centreStrokeRect(sh.x, sh.y, _cellsize,_cellsize);
		}
	}


	function drawShape() {
		ctx.clearRect(0, 0, w, h);
		ctx.backgroundObj(WHITE);

		switch (_pattern) {
			case PatternType.DOTS:
				// panel1.setValue('Pattern',3));
				drawDotsPattern();
			case PatternType.LINES:
				drawLinesPattern();
			case PatternType.HABBIT:
				drawHabbitPattern();
			case PatternType.CHALLANGE:
				draw100HabbitPattern();
			case PatternType.ISO:
				drawIsoPattern();
			case PatternType.SQUARES:
				drawSquaresPattern();
			case PatternType.POCKETBOOK:
				drawPocketBookPattern();
			case PatternType.SOCIAL:
				drawSocialPattern();
			default:
				trace("case '" + _pattern + "': trace ('" + _pattern + "');");
		}

		/*
			if (isFondEmbedded) {
				ctx.fillStyle = getColourObj(_color0);
				FontUtil.centerFillText(ctx, 'Miso MISO', w / 2, h / 2, "'Miso', sans-serif;", scaling(160));

				ctx.fillStyle = getColourObj(_color1);
				ctx.font = '${scaling(100)}px Miso';
				ctx.textAlign = 'center';
				ctx.textBaseline = 'middle';
				ctx.fillText('1234567890', w / 2, (h / 2) + scaling(200));

				var text = 'Matthijs Kamstra aka [mck]';
				ctx.fillStyle = getColourObj(_color2);
				FontUtil.create(ctx, text)
					.font('Miso')
					.centerAlign()
					.pos(w / 2, scaling(100))
					// .size(Math.round(w / 2))
					// .size(Math.round(w / text.split('').length))
					.size(scaling(50))
					.draw();

			}
		 */
	}

	// ____________________________________ utils ____________________________________

	/**
	 * [Description]
	 * @param value
	 * @return Int
	 */
	function scaling(value:Float):Int {
		return Math.round(value * dpiScale);
	}

	override function setup() {
		trace('setup: ${toString()}');

		var colorArray = ColorUtil.niceColor100SortedString[randomInt(ColorUtil.niceColor100SortedString.length - 1)];
		_color0 = hex2RGB(colorArray[0]);
		_color1 = hex2RGB(colorArray[1]);
		_color2 = hex2RGB(colorArray[2]);
		_color3 = hex2RGB(colorArray[3]);
		_color4 = hex2RGB(colorArray[4]);

		isDebug = true;

		createGrid();
	}

	override function draw() {
		trace('draw: ${toString()}');
		drawShape();
		stop();
	}
}
