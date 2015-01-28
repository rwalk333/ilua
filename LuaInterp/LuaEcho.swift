//
//  LuaEcho.swift
//
//  Echo values back to terminal through Lua C API.
//
//
//  Forked and modified from:
//
//  illua/LuaInterp at github by Matthew Burke.

import Foundation

class LuaEcho
{
    let L: COpaquePointer
    
    init()
    {
        L = luaL_newstate()
        luaL_openlibs(L)
        luaL_loadstring(L, "echo = function(x) return 'Lua got: ' .. x end")
        var err0 = lua_pcallk(L, 0, LUA_MULTRET, 0, 0, nil)
        if err0 != LUA_OK
        {
            let msg = String.fromCString(lua_tolstring(L, -1, nil))
            NSException(name: "LuaFail", reason: msg, userInfo: nil).raise()
        }
    }
    
    deinit
    {
        lua_close(L)
    }
    
    
    func evaluate(script: String) -> EvalResult
    {
        var results: [String] = []
        
        lua_settop(L, 0)
        lua_getglobal(L, "echo")
        lua_pushstring(L, script)
        println(lua_gettop(L))
        var err = lua_pcallk(L, 1, LUA_MULTRET, 0, 0, nil)
        if err != LUA_OK
        {
            let msg = String.fromCString(lua_tolstring(L, -1, nil))
            if let errmsg = msg as Optional
            {
                results.append(errmsg)
            }
            return(LUA_ERRRUN, results)
        }
        else
        {
            let n = lua_gettop(L)
            if n==1
            {
                let raw = String.fromCString(lua_tolstring(L, -1, nil))
                println(raw)
                if raw != nil {
                    let msg = raw
                    results.append(msg!)
                }
            }
            
            return (LUA_OK, results)
            
        }

    }
}

