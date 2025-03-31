# Deepdoc Retrieval Interact Action
Performs context retrieval specific to deepdoc chunks and metadata on a vector store

## Package Information

- **Name:** jivas/deepdoc_retrieval_interact_action
- **Author:** V75 Inc.
- **Architype:** DeepdocRetrievalInteractAction
- **Version:** 0.0.1

## Meta Information

- **Title:** Deepdoc Retrieval Interact Action
- **Description:** Implements a custom retrieval operations for Deepdoc against the typesense store for retrieval augmented generation tasks
- **Group:** custom
- **Type:** action

## Configuration

- **Singleton:** true

## Dependencies

- **Jivas:** ^2.0.0
- **Actions:**
  - jivas/typesense_vector_store_action: ^0.0.1

This package is design to implement a custom retrieval operation for Deepdoc against the typesense store for retrieval augmented generation tasks. It is a custom action type and is configured to be a singleton, ensuring only one instance of this action is active at any time. The package depends on specific versions of the Jivas library and one action: `typesense_vector_store_action`.
