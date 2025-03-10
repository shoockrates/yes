#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define MAX_ELEMENTS_TO_PRINT 10

typedef struct Node{
    int value;
    struct Node *next;
} Node;

typedef struct{
    Node *head;
    Node *tail;
    int size;
} Queue;

Queue *create();
int count(Queue *queue);
bool is_empty(Queue *queue);
int peek(Queue *queue, bool *status);
void enqueue(Queue *queue, int value);
int dequeue(Queue *queue, bool *status);
bool isFull(Queue* queue);
void toString(Queue *queue);
void makeEmpty(Queue *queue);
void done(Queue *queue);
Queue* clone(Queue *queue);

Queue* create(){
    /**
     * Create a new queue.
     * Initialize the head, tail, and size of the queue.
     * Return a pointer to the newly created queue.
     */
    Queue* queue = malloc(sizeof(Queue));
    
    queue->head = NULL;
    queue->tail = NULL;
    queue->size = 0;
    return queue;
}

int count(Queue *queue){
    /**
     * Count the number of elements in the queue.
     * Return the size of the queue.
     */
    return queue->size;
}

bool is_empty(Queue *queue){
    /**
     * Check if the queue is empty.
     * Return true if the queue is empty, false otherwise.
     */
    return (queue->size == 0);
}

int peek(Queue *queue, bool *status){
    /**
     * Peek at the front element of the queue without removing it.
     * If the queue is empty, set status to false and return -1.
     * If the queue is not empty, set status to true and return the value of the head element.
     */
    if(is_empty(queue))
    {
        *status = false;
        return -1;
    }
    *status = true;
    return queue->head->value;
}

void enqueue(Queue *queue, int value){
    /**
     * Enqueue a new element with the given value into the queue.
     * The element is added to the appropriate position in the queue to maintain order.
     * Update the head, tail, and size of the queue.
     */
    Node *newNode = malloc(sizeof(Node));
    
    newNode->value = value;
    newNode->next = NULL;

    if(is_empty(queue)){
        queue->head = newNode;
        queue->tail = newNode;
    }
    else {
        Node *current = queue->head;
        Node *previous = NULL;

        while (current != NULL && current->value >= value) {
            previous = current;
            current = current->next;
        }

        if (previous == NULL) {
            newNode->next = queue->head;
            queue->head = newNode;
        } else {
            previous->next = newNode;
            newNode->next = current;
        }

        if (newNode->next == NULL) {
            queue->tail = newNode;
        }
    }

    queue->size++;
}

int dequeue(Queue *queue, bool *status){
    /**
     * Dequeue an element from the front of the queue.
     * If the queue is empty, set status to false and return -1.
     * If the queue is not empty, set status to true and remove the head element.
     * Update the head, tail, and size of the queue.
     */
    if(is_empty(queue)){
        *status = false;
        return -1;
    }

    *status = true;

    int value = queue->head->value;

    Node *oldHead = queue->head;

    if(queue->size == 1){
        queue->head = NULL;
        queue->tail = NULL;
    } else{
        queue->head = queue->head->next;
    }
   
    free(oldHead);

    queue->size--;

    return value;
}

bool isFull(Queue* queue){
    /**
     * Check if the queue is full.
     * Try to allocate memory for a temporary node.
     * If memory allocation fails, return true (queue is full).
     * If memory allocation succeeds, return false (queue is not full).
     */
    Node *temp = malloc(sizeof(Node));
    if(!temp) return true;
    free(temp);
    return false;
}

void done(Queue *queue){
    /**
     * Free all elements and the queue itself.
     */
    Node *currentNode = queue->head;
    while(currentNode != NULL)
    {
        Node* temp = currentNode;
        currentNode = currentNode->next;
        free(temp);
    }
    free(queue);
}

void toString(Queue *queue){
    /**
     * Print the elements of the queue.
     * Traverse the queue and print each element's value.
     * Print up to MAX_ELEMENTS_TO_PRINT elements.
     * If more elements are present, print " -> ... ".
     */
    Node* currentNode;
    currentNode = queue->head;
    int current = 0;
    while(currentNode != NULL && current < MAX_ELEMENTS_TO_PRINT){
        printf("%d ", currentNode->value);
        currentNode = currentNode->next;

        if(currentNode != NULL && current < MAX_ELEMENTS_TO_PRINT) printf(" -> ");
        else if(currentNode != NULL && current == MAX_ELEMENTS_TO_PRINT) printf(" -> ... ");

        current++;
    }
    printf("\n");
}

Queue* clone(Queue* queue) {
    /**
     * Clone the given queue.
     * Create a new queue and copy all elements from the given queue.
     * Return the pointer to the cloned queue.
     */
    Queue* cloneQueue = create();
    Node* currentNode = queue->head;

    while (currentNode != NULL) {
        enqueue(cloneQueue, currentNode->value);
        currentNode = currentNode->next;
    }
    return cloneQueue;
}

void makeEmpty(Queue* queue){
    /**
     * Make the queue empty.
     * Free all elements in the queue and set head, tail, and size to appropriate values.
     */
    if(is_empty(queue)){
        return;
    }

    Node* currentNode = queue->head;
    Node* temp;

    while(!is_empty(queue)){
        temp = currentNode;
        free(currentNode);
        currentNode = temp->next;
        queue->size--;
    }
    queue->head = NULL;
    queue->tail = NULL;
}