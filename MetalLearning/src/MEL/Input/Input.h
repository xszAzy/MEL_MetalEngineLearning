#pragma once
#include "melpch.h"
#include <utility>
namespace MEL {
	using Keycode =uint16_t;
	namespace Key{
		enum: Keycode{
			D1			=18,
			D2			=19,
			D3			=20,
			D4			=21,
			D5			=23,
			D6			=22,
			D7			=26,
			D8			=28,
			D9			=25,
			D0			=29,
			S1			=50,//`
			S2			=33,//[
			S3			=30,//]
			S4			=42,//|
			S6			=41,//;
			S7			=39,//'
			S8			=27,//-
			S9			=24,//=
			S10			=43,//,
			S11			=47,//.
			S12			=44,//?
			N			=45,
			M			=46,
			Q			=12,
			W			=13,
			E			=14,
			R			=15,
			T			=17,
			Y			=16,
			U			=32,
			I			=34,
			O			=31,
			P			=35,
			A			=0,
			S			=1,
			D			=2,
			F			=3,
			G			=5,
			H			=4,
			J			=38,
			K			=40,
			L			=37,
			Z			=6,
			X			=7,
			C			=8,
			V			=9,
			B			=11,
			enter		=76
		};
	}
	class Input{
		static bool IsKeypressed(Keycode keycode){return IsKeyPressedImpl(keycode);}
		static bool IsMouseButtonPressed(int button){return IsMouseButtonPressedImpl(button);}
		static float GetMouseX(){return GetMouseXImpl();}
		static float GetMouseY(){return GetMouseYImpl();}
		static std::pair<float,float> GetMousePosition(){return GetMousePositionImpl();}
	private:
		static bool IsKeyPressedImpl(Keycode keycode);
		static bool IsMouseButtonPressedImpl(int button);
		static float GetMouseXImpl();
		static float GetMouseYImpl();
		static std::pair<float,float> GetMousePositionImpl();
	};
}

