local function getVersion(version)
    local versions ={
        ["2025.07.13"] = "archive/816e6f7c4cabf7d81313b503c589104c5d1292b2.tar.gz",
        ["2025.07.20"] = "archive/c18b14393f401cbfa268c7063376908dc15301a1.tar.gz",
        ["2025.07.31"] = "archive/c1db72546a63a8575d84cd53093370fc75ca55cb.tar.gz",
        --insert getVersion
    }
    return versions[tostring(version)]
end

package("borealis")
    set_homepage("https://github.com/PoloNX/borealis")
    set_description("Hardware accelerated, Nintendo Switch inspired UI library for PC, Android, iOS, PSV, PS4 and Nintendo Switch")
    set_license("Apache-2.0")

    set_urls("https://github.com/PoloNX/borealis/$(version)", {
        version = getVersion
    })
    --insert version
    add_versions("2025.07.13", "fccf07d2e56506926a9e9be326dbd2061664629be33d07ff5c85dbc24cdcdd0a")
    add_versions("2025.07.20", "cf13d7b578c19588cdf4ae84db55218036c6e410fbc5bd6995eb00554831a7d9")
    add_versions("2025.07.31", "685e801335f1e4c6e3bc7ce8487512ea35b0b28743a72e8bc923d2a02551767e")

    add_configs("window", {description = "use window lib", default = "glfw", type = "string"})
    add_configs("driver", {description = "use driver lib", default = "opengl", type = "string"})
    add_configs("winrt", {description = "use winrt api", default = false, type = "boolean"})
    add_deps(
        "nanovg",
        "yoga =2.0.1",
        "nlohmann_json",
        "fmt",
        "tweeny",
        "stb",
        "tinyxml2"
    )
    add_includedirs("include")
    if is_plat("windows") then
        add_cxflags("/utf-8")
        add_includedirs("include/compat")
        add_syslinks("wlanapi", "iphlpapi", "ws2_32")
    elseif is_plat("linux") then
        add_deps("dbus")
    end
    on_load(function (package)
        local window = package:config("window")
        local driver = package:config("driver")
        local winrt = package:config("winrt")
        if window == "glfw" then
            package:add("deps", "xfangfang_glfw")
        elseif window == "sdl" then
            package:add("deps", "sdl2")
        end
        if driver == "opengl" then
            package:add("deps", "glad =0.1.36")
        elseif driver == "d3d11" then
            package:add("syslinks", "d3d11")
        end
        if winrt then
            package:add("syslinks", "windowsapp")
        end
    end)
    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs["window"] = package:config("window")
        configs["driver"] = package:config("driver")
        configs["winrt"] = package:config("winrt") and "y" or "n"
        import("package.tools.xmake").install(package, configs)
        os.cp("library/include/*", package:installdir("include").."/")
        os.rm(package:installdir("include/borealis/extern"))
        os.cp("library/include/borealis/extern/libretro-common", package:installdir("include").."/")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <borealis.hpp>

            static void test() {
                volatile void* i = (void*)&brls::Application::init;
                if (i) {};
            }
        ]]}, {
            configs = {languages = "c++20", defines = { "BRLS_RESOURCES=\".\"" }},
        }))
    end)
