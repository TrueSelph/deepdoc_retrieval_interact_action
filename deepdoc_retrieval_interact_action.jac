import:py logging;
import:py traceback;
import:py from logging { Logger }
import:jac from agent.action.retrieval_interact_action { RetrievalInteractAction }

node DeepdocRetrievalInteractAction :RetrievalInteractAction: {
    # Integrates with vector database for retrieval augmented generation tasks

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);
    
    # the vector store action label bound to this retrieval action
    has vector_store_action:str = "TypesenseVectorStoreAction";
    has knowledge_base_url:str = "https://localhost:8501/";
    has knowledge_base_name:str = "Jivas Knowledge Bank";
    has directive:str = """
Ignore your own knowledge and assumptions. Use only CONTEXT to craft your response to the question. 
Do not include any information not found in the CONTEXT. If relevant content is not available in CONTEXT, 
advise the user that you do not have the relevant information at this time.

When including information from the CONTEXT, ensure proper citation by listing the sources at the bottom 
of your response under a **References** section. Each reference must include:

- **URL**: The source link.
- **Page Number**: The page where the information was found.
- **Document Name**: The title of the document.

### Formatting Example:

"The AI industry is evolving rapidly with new innovations in machine learning."

**References:**  
- Reference: [https://example.com](https://example.com) | Page: 5 | Document: AI_Research.pdf  
- Reference: [https://example2.com](https://example2.com) | Page: 12 | Document: Ethics_in_AI.pdf  

Only use sources available in CONTEXT. If multiple sources support a claim, list all relevant references. 

CONTEXT: 
{context}
    """;

    can retrieve_context(query:str, filter:Optional[str] = "") -> str {
        # override to implement custom retrieval operation
        
        # """
        # retrieves document for context

        # :param visitor (InteractGraphWalker) – interact graph walker state containing interaction, utterance, etc.

        # :returns string of context data relevant for RAG or None
        # """
                
        if( vector_store_action := self.get_agent().get_actions().get(action_label = self.vector_store_action) ) {
            
            texts = "";

            if(self.mmr) {
                if(documents := vector_store_action.max_marginal_relevance_search(query = query, k = self.k)) {
                    
                    for doc in documents {    
                        texts += f"{doc.page_content} ";
                        
                        # log to see doc structure
                        # self.logger.warning(f"Text1: {doc}");
                    }

                    return texts;
                }
            }
            # perform similarity search
            if(documents_and_score := vector_store_action.similarity_search_with_score(query = query, k = self.k, filter = filter)) {
            # iterate through resultset and return top-ranked texts

                for (doc, score) in documents_and_score {
                    if(self.score_threshold >= score) {
                        # grab metadata
                        metadata = doc.metadata;

                        # log to see metadata
                        # self.logger.warning(f"Metadata: {metadata}, type: {type(metadata)}, Dict: {dict(metadata)}, type: {type(dict(metadata))}");

                        # convert metadata to dict
                        metadata = dict(metadata);

                        # grab page number url and document title
                        page_number = metadata.get("page_num_int", [""])[0];
                        url = metadata.get("url");
                        document_title = metadata.get("file_name", "").split("/")[-1].strip();

                        # handle edge cases
                        if(not url or not page_number or not document_title) {
                            # use default values
                            url = self.knowledge_base_url;
                            page_number = metadata.get("collection_id");
                            document_title = self.knowledge_base_name;
                        }

                        texts += f"{doc.page_content}\nReference: {url} Page: {page_number} Document: {document_title}";
                        
                        # log to see doc structure
                        # self.logger.warning(f"Text2: {doc}");
                    }
                }

                return texts;
            }
        }

        return None;
    }
}