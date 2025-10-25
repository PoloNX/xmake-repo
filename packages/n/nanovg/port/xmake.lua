add_rules("mode.debug", "mode.release")

option("freetype")
    set_default(false)
    set_showmenu(true)
option_end()

add_repositories("zeromake https://github.com/zeromake/xrepo.git")
add_repositories("polonx https://github.com/PoloNX/xmake-repo.git")

add_requires("stb")
add_requires("polonx@sokol-sdhc", {alias = "sokol-sdhc"})
add_defines("NVG_USE_SHD_SHADER")

if get_config("freetype") then
    add_requires("freetype")
end

if is_plat("windows") then
    add_cxflags("/utf-8")
end

target("nanovg")
    set_kind("$(kind)")
    add_files(
        "src/nanovg.c"
    )
    add_packages("stb")
    add_headerfiles("src/*.h")
    if get_config("freetype") then
        add_defines("FONS_USE_FREETYPE")
        add_packages("freetype")
    end
target_end()

if is_plat("macosx") then
target("nanovg_metal")
    set_kind("$(kind)")
    add_includedirs("src")
    add_headerfiles("src/metal/*.h")
    add_files("src/metal/nanovg_mtl.m")
    add_files("src/metal/metal_helper.mm")
target_end()
end

if is_plat("windows", "mingw") then
    target("nanovg_d3d11")
        set_kind("$(kind)")
        add_includedirs("src")
        add_headerfiles("src/d3d11/*.h")
        add_headerfiles("src/d3d11/nvg_shader/*.h", {prefixdir="nvg_shader"})
        add_files("src/d3d11/d3d11_helper.c")
    target_end()
end

target("nanovg_wrapper")
    set_kind("object")
    if is_plat("macosx") then
        add_files("src/nanovg_wrapper.mm")
    end
target_end()
