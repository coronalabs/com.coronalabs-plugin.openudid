local Library = require "CoronaLibrary"

-- Create library
local lib = Library:new{ name='plugin.openudid', publisherId='com.coronalabs' }

lib.getValue = function()
	print( "WARNING: The 'plugin.openudid' library is not available on this platform." )
	print( "WARNING: openudid.getValue() will not return a unique value" )

	return "not-a-unique-value"
end

lib.setOptOut = function()
	print( "WARNING: The 'plugin.openudid' library is not available on this platform." )
	print( "WARNING: openudid.setOptOut() does not do anything" )
end

-- Return an instance
return lib
