package model.constants;

import haxe.macro.Context;

class App {

	public static inline var URL : String  = "https://";

	public static var NAME : String = "[cc-init]";

	public static var BUILD : String = getBuildDate();

	macro public static function getBuildDate() {
		var date = Date.now().toString();
		return Context.makeExpr(date, Context.currentPos());
	}

}