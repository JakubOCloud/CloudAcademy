# Kafka Questions

## Part 1

### How does Kafka distribute data between partitions and what are the implications?

Kafka stores messages in partitions. When a producer sends a message, Kafka uses the message key to decide which partition should receive it. Messages with the same key normally go to the same partition.

In our project, the `order_id` is used as the key. This means events for the same order stay in the same partition.

The main implication is that Kafka can process different partitions in parallel, but ordering is only guaranteed inside one partition.

---

### What stores the offset and where does it "live"?

The offset tells Kafka where a consumer stopped reading messages.

Kafka stores consumer group offsets in its internal `__consumer_offsets` topic. The offset is associated with a consumer group, topic and partition.

In our Processor, offsets are committed manually after successful processing.

---

### What happens if the processor crashes during processing?

If the Processor crashes before committing the offset, Kafka still considers that message unprocessed.

After the Processor starts again, the consumer group can read the message again.

This can lead to the same event being processed more than once, so applications should be designed to handle possible duplicates.

Our Processor uses manual commits, so the offset is committed only after processing finishes.

---

### In what sense does Kafka "remember history" and what deletes it?

Kafka does not immediately delete a message after a consumer reads it.

Messages stay in the topic for a configured retention period. Consumers can read old messages again using their offsets or a new consumer group.

In our setup, the topics have a retention time of 1 hour.

After the retention period, Kafka removes old messages automatically.

---

### When is data replay necessary in practice?

Replay is useful when we need to process old events again.

For example, it can be needed after fixing a bug in the Processor, changing the processing logic, rebuilding a database, or creating a new service that needs historical events.

In our project, we demonstrated replay by creating a new consumer group and reading `system-events-raw` from the beginning.

---

## Part 2

### Why doesn't Apache Kafka guarantee global event ordering?

Kafka only guarantees ordering inside a single partition.

When a topic has multiple partitions, messages can be processed in parallel by different consumers. Because of this, Kafka cannot guarantee one global order for the whole topic.

If strict ordering is required for related events, they should use the same key so they end up in the same partition.

---

### What determines how many consumer instances actually process data?

The number of partitions is the main limitation.

Within one consumer group, one partition can be assigned to only one consumer at a time.

For example, with 3 partitions, up to 3 consumers can actively process data in parallel.

In our project, the Processor was scaled to 3 replicas and the 3 partitions were distributed between them.

---

### What happens when the number of consumers exceeds the number of partitions?

Some consumers will have no partition assigned to them.

For example, with 3 partitions and 5 consumers, only 3 consumers can process messages. The other 2 consumers stay idle until more partitions become available or the group changes.

This is why simply adding more consumer replicas does not always increase performance.

---

### What are the risks of frequent rebalancing in a production system?

During a rebalance Kafka redistributes partitions between consumers.

Frequent rebalancing can temporarily stop or slow down processing. It can also increase latency and create extra load on Kafka and the consumers.

In production, frequent pod restarts, unstable consumers or badly configured timeouts can cause unnecessary rebalances.

---

### How should you design an event key to preserve ordering while still enabling scaling?

The key should represent the entity for which ordering is important.

For example, if all events for the same order must stay in order, use `order_id` as the key.

This keeps all events for one order in the same partition while allowing different orders to be distributed across different partitions.

In our Publisher, `order_id` is used as the Kafka message key.

---

## Part 3

### Why doesn't Apache Kafka "update" events?

Kafka is an event log, not a traditional database.

When a new event is produced, Kafka normally appends a new record instead of changing an old one.

For example, instead of updating an existing `order_created` event, we could produce another event such as `order_updated`.

The old event can still remain in Kafka until it expires according to the retention policy.

---

### What happens if the Processor crashes during processing?

In our implementation, the Processor commits the offset manually after successful processing.

If it crashes before the commit, the offset is not saved as completed. After a restart, the message can be processed again.

This gives us at-least-once processing, but it also means duplicate processing is possible.

---

### What are the differences between at-most-once and at-least-once?

**At-most-once** means a message is processed zero or one time. A message can be lost, but it should not be processed twice.

**At-least-once** means a message should not be lost, but it can be processed more than once.

Our Processor follows the at-least-once approach because it commits the offset after processing.

---

### Why is DLQ a key element of a data pipeline?

A DLQ (Dead Letter Queue) stores messages that cannot be processed correctly.

Instead of stopping the whole pipeline because of one bad message, the Processor sends the invalid event to the DLQ and continues processing other events.

In our project, invalid events can be sent to `system-events-dlq` with information about the error and the original message.

This makes debugging and later recovery much easier.

---

### In what situations is data replay actually used in production?

Replay is commonly used after bugs, data processing errors, migrations or changes in business logic.

For example, if a Processor had a bug and produced incorrect results for several hours, the original events can be replayed after fixing the bug.

It can also be useful when a new service needs to build its initial state from historical events.

---

## Part 4

### What role does Strimzi play compared to deploying Kafka manually on Kubernetes?

Strimzi makes running Kafka on Kubernetes much easier.

Instead of manually creating and managing Kafka Deployments, Services, storage and other resources, we define a Kafka custom resource and Strimzi manages the Kafka cluster for us.

Strimzi also provides Kubernetes resources such as `Kafka`, `KafkaNodePool` and `KafkaTopic`.

This is much easier to manage than manually building the whole Kafka setup from standard Kubernetes Deployments.

---

### Why can't applications in Kubernetes use localhost to communicate with Kafka?

Inside a Kubernetes pod, `localhost` means the current pod itself.

So if the Processor uses `localhost:9092`, it would try to connect to Kafka inside the Processor pod, which is not where Kafka is running.

Kubernetes provides Services and DNS for communication between pods.

In our project, applications connect to:

`kafka-cluster-kafka-bootstrap:9092`

instead of `localhost:9092`.

---

### What happens to data processing when a consumer pod is restarted?

When a consumer pod is restarted, Kafka notices that the consumer left the group.

The group performs a rebalance and the partitions are assigned again to the available consumers.

Because the consumer group stores committed offsets, the new Processor can continue from the last committed position.

If the crash happened before an offset was committed, the message can be processed again.

---

### How does Kubernetes influence consumer group rebalancing?

Kubernetes controls the number and lifecycle of Processor pods.

When we scale the Deployment up or down, restart a pod or Kubernetes replaces a failed pod, the number of consumers in the Kafka consumer group changes.

Kafka then performs a rebalance and redistributes the partitions between the available consumers.

So Kubernetes does not perform the Kafka rebalance itself. Kubernetes changes the set of running consumers, and Kafka handles the consumer group and partition assignment.

---

### Which parts of this setup are not production-ready, and why?

This setup is mainly for learning and local development.

The biggest limitations are:

- We use a single Kafka broker, so there is no broker redundancy.
- Kafka topics use replication factor `1`, so there are no replicas of the data.
- Storage is local Minikube storage, not production-grade distributed storage.
- Kafka and the applications do not use TLS or authentication.
- The setup is running locally on one machine.
- Monitoring and alerting are very basic.
- The Publisher is implemented as a Deployment even though it is a finite process, so it can restart and publish events again.
- There are no proper production resource limits, autoscaling policies or high-availability configuration.

So the setup is good for demonstrating Kafka, Kubernetes, Strimzi, consumer groups, replay and durability, but it should not be treated as a production architecture.