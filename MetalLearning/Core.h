#pragma once

#include<memory>
#define BIT(x)(1<<x)
#define MEL_BIND_EVENT_FN(fn) std::bind(&fn, this, std::placeholders::_1)

namespace MEL{
	template<typename T>
	using Scope=std::unique_ptr<T>;
	
	template<typename T>
	using Ref=std::shared_ptr<T>;
}

