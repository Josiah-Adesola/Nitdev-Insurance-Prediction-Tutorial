import os

import streamlit as st
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Chroma
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_groq import ChatGroq
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

st.set_page_config(page_title="Company Policy Q&A", page_icon="🤖")
st.title("🤖 Company Policy Q&A (RAG + Groq)")

# --- Groq API key, entered in the sidebar ---
api_key = st.sidebar.text_input(
    "Groq API Key", type="password", help="Get one free at console.groq.com"
)
if not api_key:
    st.info("Enter your Groq API key in the sidebar to get started.")
    st.stop()
os.environ["GROQ_API_KEY"] = api_key


@st.cache_resource(show_spinner="Loading knowledge base...")
def build_rag_chain(_api_key: str):
    with open("company_policy.txt", "w") as f:
        f.write(
            "The remote work policy allows employees to work from anywhere up to 3 days a week. "
            "Core collaboration hours are between 10:00 AM and 3:00 PM EST. "
            "Employees receive a $500 home office stipend upon onboarding."
        )

    docs = TextLoader("company_policy.txt").load()
    chunks = RecursiveCharacterTextSplitter(chunk_size=150, chunk_overlap=20).split_documents(docs)

    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
    vector_store = Chroma.from_documents(chunks, embeddings)
    retriever = vector_store.as_retriever(search_kwargs={"k": 2})

    llm = ChatGroq(model="llama-3.1-8b-instant", temperature=0)
    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "You are an assistant for question-answering tasks.\n"
                "Use the following pieces of retrieved context to answer the question.\n"
                "If you don't know the answer, say that you don't know.\n\nContext:\n{context}",
            ),
            ("human", "{input}"),
        ]
    )

    def format_docs(docs):
        return "\n\n".join(doc.page_content for doc in docs)

    return (
        {"context": retriever | format_docs, "input": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )


rag_chain = build_rag_chain(api_key)

question = st.text_input(
    "Ask a question about the company policy:",
    placeholder="How much money do I get for setting up my home office?",
)

if st.button("Ask") and question:
    with st.spinner("Thinking..."):
        answer = rag_chain.invoke(question)
    st.write(answer)
