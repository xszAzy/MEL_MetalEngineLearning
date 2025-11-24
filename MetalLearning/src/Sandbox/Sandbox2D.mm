#include "Sandbox2D.h"
#include "imgui.h"
#include "MEL.h"

Sandbox2D::Sandbox2D():MEL::Layer("Sandbox2D"){
	MEL::Render(MEL::Application::Get().GetRenderer());
}

void Sandbox2D::OnAttach(){
	MEL::CameraController::OrthographicController(-1.0f, 1.0f, -1.0f, 1.0f, 0.1f, 100.f);
	m_CameraController.SetPosition({0,0,1});
	MEL::Render::SetCamera(m_CameraController);
	
	
	//set layout
	MEL::BufferLayout layout={
		{MEL::ShaderDataType::Float3,"a_Position"},
		{MEL::ShaderDataType::Float4,"a_Color"}
	};
	struct Vertex{
		float position[3];
		float color[4];
	};
	
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
	
	auto va=MEL::Render::CreateVA(SquareVertices,sizeof(SquareVertices),
								  SquareIndices,sizeof(SquareIndices),
								  layout);
	
	auto Square=std::make_shared<MEL::GameObject>("Square");
	Square->SetVertexArray(va);
	//Square->GetTransform().SetScale({2,2,2});
	Square->GetTransform().SetPosition({0,0,.1f});
	m_GameObjects.push_back(Square);
	
	Vertex SquareVertices1[]={
		{{-0.5f,-0.5f,0.0f},
			{0.4f,0.2f,0.4f,1.0f}},
		
		{{0.5f,-0.5f,0.0f},
			{0.1f,0.7f,0.1f,1.0f}},
		
		{{0.5f,0.5f,0.0f},
			{0.1f,0.3f,0.4f,1.0f}},
		
		{{-0.5f,0.5f,0.0f},
			{0.2f,0.3f,0.1f,1.0f}}
	};
	
	uint32_t SquareIndices1[]={0,1,2,
		2,3,0};
	
	auto va1=MEL::Render::CreateVA(SquareVertices1, sizeof(SquareVertices1),
								   SquareIndices1, sizeof(SquareIndices1),
								   layout);
	auto Square1=std::make_shared<MEL::GameObject>("AnotherSquare");
	Square1->SetVertexArray(va);
	Square1->GetTransform().SetPosition({0.5f,0.5f,0.0f});
	m_GameObjects.push_back(Square1);
	
	MEL::Render::LoadShaderFromFile("Sandbox2D", "Sandbox2D.txt",
									@"vertexMain", @"fragmentMain",
									layout,MEL::BlendType::Opaque);
	
	MEL::BufferLayout TextureLayout={
		{MEL::ShaderDataType::Float3,"a_Position"},
		{MEL::ShaderDataType::Float4,"a_Color"},
		{MEL::ShaderDataType::Float2,"a_TexCoord"}
	};
	struct TextureVertex{
		float position[3];
		float color[4];
		float texCoord[2];
	};
	
	TextureVertex TextureVertices[]={
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
	
	uint32_t TextureIndices[]={0,1,2,
		2,3,0};
	
	auto TextureSquare=std::make_shared<MEL::GameObject>("TextureSquare");
	TextureSquare->SetVertexArray(MEL::Render::CreateVA(TextureVertices, sizeof(TextureVertices),
														TextureIndices, sizeof(TextureIndices),
														TextureLayout));
	TextureSquare->GetTransform().SetPosition({-.5f,-.5f,0});
	TextureSquare->SetTexture("test.png");
	m_GameObjects.push_back(TextureSquare);
	MEL::Render::LoadShaderFromFile("Texture2D", "Texture.metal.txt", @"vertexShader", @"fragmentShader", TextureLayout);
}

void Sandbox2D::OnDetach(){
	
}

void Sandbox2D::OnUpdate(MEL::Timestep ts){
	MEL::Render::UpdateCamera(ts);
	float WhiteColor[4]={1,1,1,1};
	MEL::Render::Draw(m_GameObjects, 0, m_SquareColor, "Sandbox2D", true, false);
	MEL::Render::Draw(m_GameObjects,1,WhiteColor,"Sandbox2D",true,false);
	
	MEL::Render::Draw(m_GameObjects, 2, WhiteColor, "Texture2D", true, true);
}

void Sandbox2D::OnImGuiRender(){
	ImGui::Begin("Setting");
	ImGui::ColorEdit4("SquareColor", m_SquareColor);
	ImGui::End();
}
void Sandbox2D::OnEvent(MEL::Event &e){
	m_CameraController.OnEvent(e);
}
