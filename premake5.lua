workspace "MEL"
	configurations {"Debug",
					"Release"}
	platforms {"x64"}

	outputdir= "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
-- Include directories relative to root folder (solution directory)
IncludeDir={}
IncludeDir["spdlog"]="MetalLearning/vendor/spdlog/include"
IncludeDir["ImGui"]="MetalLearning/vendor/imgui"

include "MetalLearning/vendor/imgui"

project "MetalLearning"
	location "MetalLearning"
	kind "WindowedApp"
	language "C++"
	staticruntime "on"
	
	targetdir("bin/" .. outputdir .. "/%{prj.name}")
    objdir("bin-int/" .. outputdir .. "/%{prj.name}")
	
	files
	{
		"%{prj.name}/src/**.h",
        "%{prj.name}/src/**.cpp",
        "%{prj.name}/src/**.mm",
		"%{prj.name}/src/**.m",
		"%{prj.name}/*.h",
		"%{prj.name}/ShaderSrc/**.metal",
		"%{prj.name}/vendor/imgui/backends/imgui_impl_osx.mm",
		"%{prj.name}/vendor/imgui/backends/imgui_impl_metal.mm"
	}
	
	includedirs
	{
		"**",
		"%{prj.name}/ShaderSrc",
        "%{IncludeDir.spdlog}",
        "%{IncludeDir.ImGui}",
	}

	links
	{
-- link directories here
		"ImGui",
	}

	filter "system:macosx"
		system "macosx"
		defines
		{
			"MEL_PLATFORM_MAC"
		}

		links
		{
		"Metal.framework",
		"Cocoa.framework",
        "QuartzCore.framework",
        "CoreFoundation.framework",
        "CoreGraphics.framework",
        "MetalKit.framework",
        "GameController.framework"
		}
		
	xcodebuildsettings{
            ["MACOSX_DEPLOYMENT_TARGET"]="10.15",
            ["GCC_PRECOMPILE_PREFIX_HEADER"]="NO",
            ["ALWAYS_SEARCH_USER_PATHS"]="YES",
            ["HEADER_SEARCH_PATHS"]=
            {
            "$(SRCROOT)/vendor/spdlog/include",
            },
            ["GCC_INCREASE_PRECOMPILED_HEADER_SHARING"]="YES",
            ["GCC_INPUT_FILETYPE"]="sourcecode.cpp.objcpp",
            ["GENERATE_INFOPLIST_FILE"]="YES"
		}


	filter "configurations:Debug"
		defines"MEL_DEBUG"
		runtime "Debug"
		symbols "on"

	filter "configurations:Release"
        defines "MEL_RELEASE"
        runtime "Release"
        optimize "on"

