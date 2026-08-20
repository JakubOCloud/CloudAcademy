## How does Kafka distribute data between partitions and what are the implications?

Kafka distributes messages between partitions using a partitioning strategy. If a message has a key, messages with the same key usually go to the same partition. Without a key, Kafka can distribute messages between partitions.

The main implication is that partitions allow Kafka to process data in parallel. More partitions can mean higher performance, but the order of messages is guaranteed only **within a single partition**, not across the whole topic.

## What stores the offset and where does it "live"?

The offset is the position of a message inside a partition.

Kafka stores consumer offsets in a special internal topic called `__consumer_offsets`. The offset belongs to a **consumer group**, so Kafka knows which message each consumer group has already processed.

## What happens if the processor crashes during processing?

If the processor crashes before committing the offset, Kafka will consider the message unprocessed. After the processor restarts, it can read the message again.

This can cause the message to be processed more than once. Therefore, consumers should ideally be designed to handle duplicate messages safely.

## In what sense does Kafka "remember history" and what deletes it?

Kafka keeps messages in its log even after a consumer has read them. Consumers can use the stored offsets to know where they stopped and can read older messages again.

Kafka eventually deletes old messages according to the topic's **retention settings**, such as retention time or storage size. Kafka itself, not the consumer, normally decides when old data is removed.

## When is data replay necessary in practice?

Data replay is useful when messages need to be processed again.

For example, replay can be necessary when:

* a bug was found in the processing logic,
* a new service needs to process old events,
* data was lost or processed incorrectly,
* a database needs to be rebuilt from events,
* a new version of the application needs to recalculate results.

Kafka makes this possible because messages remain available for the configured retention period.
