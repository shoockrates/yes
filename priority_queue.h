#ifndef PRIORITY_QUEUE_H
#define PRIORITY_QUEUE_H

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

#endif /* QUEUE_H */
