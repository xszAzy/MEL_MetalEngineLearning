#include "MEL.h"
#include "imgui.h"
#include <stdio.h>
#include "MacInput.h"

#include "Core.h"
#include "RenderCommand.h"
#include "Core/Timestep.h"

#include "GameObject.h"

class ExampleLayer:public MEL::Layer{
public:
	ExampleLayer()
	:Layer("Example"){
		
	}
	void OnImGuiRender()override{
		ImGui::Begin("MEL Engine - Metal Implementation");
		ImGui::Text("Hello, Metal! This is your engine");
		
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",1000.0f/ImGui::GetIO().Framerate,ImGui::GetIO().Framerate);
		ImGui::ColorEdit3("Triangle Color", m_TriColor);
		static bool show=1;
		if(show){
			//ImGui::ShowDemoWindow(&show);
		}
		ImGui::End();
	}
	
	void OnUpdate(MEL::Timestep ts) override{
		//MEL_INFO("testing update");
#pragma mark - move controll
		m_CameraController.OnUpdate(ts);
#pragma mark - other sets
		m_Renderer->UpdateCameraUniform();
			
		for(size_t i=0;i<m_GameObjects.size();i++){
			auto& obj=m_GameObjects[i];
			//other settings
			if(i!=0){
				//bind transform
				obj->BindTransform();
				if(i==1)
					obj->SetColor({m_TriColor[0],m_TriColor[1],m_TriColor[2]});
				MEL::RenderCommand::Submit(m_Renderer->GetShaderLibrary().Get("Default"), obj->GetVertexArray());
			}
			if(i==0){
				//bind transform
				obj->BindTransform();
				obj->BindTexture();
				MEL::RenderCommand::Submit(m_Renderer->GetShaderLibrary().Get("TextureShader"), obj->GetVertexArray());
			}
			
			
		}
	}
	
	void OnAttach() override{
		
		m_Renderer=MEL::Application::Get().GetRenderer();
		
		//shadersource
		
		const char* ShaderSource=R"(
  #include <metal_stdlib>
  using namespace metal;
  
  struct VertexIn{
  float3 position[[attribute(0)]];
  float4 color[[attribute(1)]];
  };
  
  struct TransformData{
  float4x4 modelMatrix;
  float4 color;
  };
  
  struct CameraData{
  float4x4 viewProjectionMatrix;
  float3 cameraPosition;
  float padding;
  };
  
  struct VertexOut{
  float4 position[[position]];
  float4 color;
  };
  
  vertex VertexOut vertexMain(const VertexIn in [[stage_in]],
  constant CameraData& cameraData [[buffer(1)]],
  constant TransformData& transformData [[buffer(2)]]){
  VertexOut out;
  float4 worldPosition=transformData.modelMatrix*float4(in.position,1.0);
  out.position=cameraData.viewProjectionMatrix*worldPosition;
  out.color=transformData.color;
  return out;
  }
  
  fragment float4 fragmentMain(VertexOut in [[stage_in]]){
  return in.color;
  }
  )";
		
#pragma mark - Set source
		//set camera
		MEL::CameraController::PerspectiveController(60.0f, 16.0f/9.0f, 0.1f, 100.0f);
		//MEL::CameraController::OrthographicController(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 100.f);
		m_CameraController.SetPosition({0.0f,0.0f,3.0f});
		m_CameraController.LookAt({.0f,.0f,.0f});
		m_Renderer->SetSceneCamera(m_CameraController.GetCamera());
		
		CreateObjects();
		//create shader(this can be done in sandbox)
		auto textureShader=m_Renderer->GetShaderLibrary().LoadFromFile("TextureShader","Texture.metal.txt",
																	   @"vertexShader", @"fragmentShader",m_TextureLayout);
		auto alterShader=m_Renderer->GetShaderLibrary().LoadFromSource("Default", ShaderSource,
																	   @"vertexMain", @"fragmentMain",m_DefaultLayout);
	}
	
	void OnEvent(MEL::Event& e) override{
		MEL_INFO("testing event{0}",e.ToString());
		m_CameraController.OnEvent(e);
	}
#pragma mark - Create objects
public:
	void CreateObjects(){
		//create square
		auto squareObject=std::make_shared<MEL::GameObject>("Square");
		squareObject->SetVertexArray(CreateSquareVAWithTexture());
		squareObject->GetTransform().SetPosition({-1.0f,-1.0f,0.0f});
		//squareObject->GetTransform().SetScale({0.1f,0.1f,0.1f});
		squareObject->SetColor({1,0,0});
		squareObject->SetTexture("square.jpg");
		
		m_GameObjects.push_back(squareObject);
		
		//create triangle
		auto triangleObject=std::make_shared<MEL::GameObject>("Triangle");
		triangleObject->SetVertexArray(CreateTriVA());
		triangleObject->GetTransform().SetPosition({0,0,0});
		triangleObject->SetColor({m_TriColor[0],m_TriColor[1],m_TriColor[2]});
		
		m_GameObjects.push_back(triangleObject);
		//create extra
		for(size_t i=0;i<6;i++){
			for(size_t j=0;j<6;j++){
				auto extraObject=std::make_shared<MEL::GameObject>("extra");
				extraObject->SetVertexArray(CreateSquareVA());
				extraObject->GetTransform().SetScale({0.1f,0.1f,0.1f});
				extraObject->GetTransform().SetPosition({0.11f*i,0.11f*j,0});
				extraObject->SetColor({.0f,.0f,1.0f});
				
				m_GameObjects.push_back(extraObject);
			}
		}
		 
	}
#pragma mark - private objects
private:
	MEL::Ref<MEL::VertexArray> CreateSquareVA(){
		//set vertex layout
		struct Vertex{
			float position[3];
			float color[4];
		};
		//set layout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"}
		};
		MEL_CORE_INFO("Set layout for square");
		auto va=MEL::VertexArray::Create();
		//set data
		Vertex SquareVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.4f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.5f,0.5f,0.0f},
				{0.1f,0.3f,0.4f,1.0f}},
			
			{{-0.5f,0.5f,0.0f},
				{0.2f,0.3f,0.1f,1.0f}}
		};
		
		uint32_t SquareIndices[]={0,1,2,
			2,3,0};
		//Set buffers
		auto SquareVB=MEL::VertexBuffer::Create(SquareVertices, sizeof(SquareVertices));
		auto SquareIB=MEL::IndexBuffer::Create(SquareIndices, 6);
		SquareVB->SetSlot(0);
		SquareVB->SetLayout(layout);
		
		va->AddVertexBuffer(SquareVB);
		va->SetIndexBuffer(SquareIB);
		return va;
	}
	MEL::Ref<MEL::VertexArray> CreateTriVA(){
		//set vertex layout
		struct Vertex{
			float position[3];
			float color[4];
		};
		//set layout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"}
		};
		MEL_CORE_INFO("Set layout for triangle");
		auto va=MEL::VertexArray::Create();
		
		Vertex TriVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.8f,0.2f,0.4f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f}},
			
			{{0.0f,0.5f,0.0f},
				{0.0f,0.2f,0.8f,1.0f}}
		};
		
		uint32_t TriIndices[]={0,1,2};
		//set buffers
		auto TriVB=MEL::VertexBuffer::Create(TriVertices, sizeof(TriVertices));
		auto TriIB=MEL::IndexBuffer::Create(TriIndices, 3);
		TriVB->SetSlot(0);
		TriVB->SetLayout(layout);
		
		va->AddVertexBuffer(TriVB);
		va->SetIndexBuffer(TriIB);
		return va;
	}
	MEL::Ref<MEL::VertexArray> CreateSquareVAWithTexture(){
		//set vertex layout
		struct Vertex{
			float position[3];
			float color[4];
			float texCoord[2];
		};
		//set layout
		MEL::BufferLayout layout={
			{MEL::ShaderDataType::Float3,"a_Position"},
			{MEL::ShaderDataType::Float4,"a_Color"},
			{MEL::ShaderDataType::Float2,"a_TexCoord"}
		};
		MEL_CORE_INFO("Set layout for square with texture");
		auto va=MEL::VertexArray::Create();
		//set data
		Vertex SquareVertices[]={
			{{-0.5f,-0.5f,0.0f},
				{0.4f,0.2f,0.4f,1.0f},
				{1.0f,1.0f}},
			
			{{0.5f,-0.5f,0.0f},
				{0.1f,0.7f,0.1f,1.0f},
				{0.0f,1.0f}},
			
			{{0.5f,0.5f,0.0f},
				{0.1f,0.3f,0.4f,1.0f},
				{0.0f,0.0f}},
			
			{{-0.5f,0.5f,0.0f},
				{0.2f,0.3f,0.1f,1.0f},
				{1.0f,0.0f}}
		};
		
		uint32_t SquareIndices[]={0,1,2,
			2,3,0};
		//Set buffers
		auto SquareVB=MEL::VertexBuffer::Create(SquareVertices, sizeof(SquareVertices));
		auto SquareIB=MEL::IndexBuffer::Create(SquareIndices, 6);
		SquareVB->SetSlot(0);
		SquareVB->SetLayout(layout);
		
		va->AddVertexBuffer(SquareVB);
		va->SetIndexBuffer(SquareIB);
		return va;
	}
	
private:
	MEL::Renderer* m_Renderer;
	
	MEL::CameraController m_CameraController;
	
	std::vector<MEL::Ref<MEL::GameObject>> m_GameObjects;
	MEL::Ref<MEL::Shader> m_TextureShader;
	MEL::Ref<MEL::Shader> m_DefaultShader;
	MEL::BufferLayout m_TextureLayout={
		{MEL::ShaderDataType::Float3,"a_Position"},
		{MEL::ShaderDataType::Float4,"a_Color"},
		{MEL::ShaderDataType::Float2,"a_texCoord"}
	};
	MEL::BufferLayout m_DefaultLayout={
		{MEL::ShaderDataType::Float3,"a_Position"},
		{MEL::ShaderDataType::Float4,"a_Color"}
	};
	
	float m_TriColor[4]={0.2,0.3,0.6,1.0};
};

class Sandbox:public MEL::Application{
public:
	Sandbox(){
		PushLayer(new ExampleLayer());
		
	}
	~Sandbox(){
		
	}
private:
	
};

MEL::Application* MEL::CreateApplication(){
	return new Sandbox();
}
