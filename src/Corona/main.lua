local openudid = require "plugin.openudid"

local udid,err = openudid.getValue()
native.showAlert(
	"UDID",
	string.format( "id(%s) err(%s)", udid, tostring(err) ),
	{ "OK" } )
