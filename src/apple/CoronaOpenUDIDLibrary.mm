// ----------------------------------------------------------------------------
// 
// CoronaOpenUDIDLibrary.cpp
// Copyright (c) 2013 Corona Labs Inc. All rights reserved.
// 
// ----------------------------------------------------------------------------

#include "CoronaOpenUDIDLibrary.h"

#include "CoronaAssert.h"
#include "CoronaLibrary.h"
#include "CoronaRuntime.h"

#import "OpenUDID.h"
#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------

namespace Corona
{

// ----------------------------------------------------------------------------

class OpenUDIDLibrary
{
	public:
		typedef OpenUDIDLibrary Self;

	public:
		static const char kName[];

	protected:
		OpenUDIDLibrary();

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int getValue( lua_State *L );
		static int setOptOut( lua_State *L );
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.openudid"
const char OpenUDIDLibrary::kName[] = "plugin.openudid";

OpenUDIDLibrary::OpenUDIDLibrary()
{
}

int
OpenUDIDLibrary::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "getValue", getValue },
		{ "setOptOut", setOptOut },

		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;

	// Store the library singleton in the registry so it persists
	// using kMetatableName as the unique key.
	CoronaLuaPushUserdata( L, library, kMetatableName );
	lua_pushstring( L, kMetatableName );
	lua_settable( L, LUA_REGISTRYINDEX );

	// Leave "library" on top of stack
	// Set library as upvalue for each library function
	int result = CoronaLibraryNew( L, kName, "com.coronalabs", 1, 1, kVTable, library );

	return result;
}

int
OpenUDIDLibrary::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

	delete library;

	return 0;
}

OpenUDIDLibrary *
OpenUDIDLibrary::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

// [Lua] library.getValue()
int
OpenUDIDLibrary::getValue( lua_State *L )
{
	NSError *error = nil;
	NSString *value = [Corona_OpenUDID valueWithError:&error];

	const char *udid = "";
	if ( value )
	{
		udid = [value UTF8String];
	}
	int numResults = 1;
	lua_pushstring( L, udid );

	if ( error )
	{
		NSString *description = [error localizedDescription];
		lua_pushstring( L, [description UTF8String] );
		++numResults;
	}

	return numResults;
}

// [Lua] library.setOptOut( value )
int
OpenUDIDLibrary::setOptOut( lua_State *L )
{
	bool value = lua_toboolean( L, 1 );

	[Corona_OpenUDID setOptOut:value];

	return 0;
}

// ----------------------------------------------------------------------------

} // namespace Corona

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_openudid( lua_State *L )
{
	return Corona::OpenUDIDLibrary::Open( L );
}
