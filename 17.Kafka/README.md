# PART 1

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

# PART 2

## Kafka Scaling and Ordering

### Why doesn't Apache Kafka guarantee global event ordering?

Kafka guarantees ordering only within a single partition. Since a topic can have multiple partitions that are processed in parallel, Kafka cannot guarantee one global order for all events in the topic.

For example:

- Partition 0 has: `A → B → C`
- Partition 1 has: `D → E → F`

The order inside each partition is preserved, but there is no global order between the two partitions.

---

### What determines how many consumer instances actually process data?

The number of partitions determines the maximum number of consumer instances that can actively process data within one consumer group.

If a topic has 3 partitions:

- 1 consumer can process all 3 partitions.
- 2 consumers can process the partitions in parallel.
- 3 consumers can each process one partition.
- More than 3 consumers cannot increase parallelism.

Therefore, the number of partitions is the main limit for consumer parallelism.

---

### What happens when the number of consumers exceeds the number of partitions?

When there are more consumers than partitions, some consumers remain idle because there are no partitions available for them.

For example, with 3 partitions and 4 consumers:

```text
Consumer 1 → Partition 0
Consumer 2 → Partition 1
Consumer 3 → Partition 2
Consumer 4 → no partition