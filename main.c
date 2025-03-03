#include <stdio.h>
#include <stdlib.h>
#include "priority_queue.h"

int main() 
{
    Queue *queue = create();

    if (queue != NULL){
        printf("Queue created successfully\n");
    }  

    enqueue(queue, 5);
    printf("\nElement 5 enqueued\n");
    enqueue(queue, 3);
    printf("Element 3 enqueued\n");
    enqueue(queue, 7);
    printf("Element 7 enqueued\n"); 
    enqueue(queue, 2);
    printf("Element 2 enqueued\n");
    enqueue(queue, 4);
    printf("Element 4 enqueued\n");
    enqueue(queue, 6);
    printf("Element 6 enqueued\n");
    enqueue(queue, 8);
    printf("Element 8 enqueued\n");
    enqueue(queue, 1);
    printf("Element 1 enqueued\n");
    enqueue(queue, 9);
    printf("Element 9 enqueued\n");
    enqueue(queue, 10);
    printf("Element 10 enqueued\n\n");

    printf("Queue size: %d\n", count(queue));
    printf("Queue is empty: %d\n", is_empty(queue));
    printf("Queue is full: %d\n", isFull(queue));

    toString(queue);

    bool status = false;
    printf("\nDequeued element: %d\n", dequeue(queue, &status));
    printf("Dequeued element: %d\n", dequeue(queue, &status));
    printf("Dequeued element: %d\n", dequeue(queue, &status));
    printf("Dequeued element: %d\n", dequeue(queue, &status));
    printf("Dequeued element: %d\n", dequeue(queue, &status));

    printf("Queue size: %d\n", count(queue));
    printf("Queue is empty: %d\n", is_empty(queue));
    printf("Queue is full: %d\n", isFull(queue));
    
    toString(queue);

    Queue *clonedQueue = clone(queue);
    toString(clonedQueue);
    printf("Cloned queue size: %d\n", count(clonedQueue));
    printf("Cloned queue is empty: %d\n", is_empty(clonedQueue));

    makeEmpty(queue);
    printf("Queue emptied\n");
    printf("Queue size: %d\n", count(queue));
    printf("Queue is empty: %d\n", is_empty(queue));
    printf("Queue is full: %d\n\n", isFull(queue));

    done(clonedQueue);
    done(queue);
    printf("Queues destroyed\n");
    return 0;
}