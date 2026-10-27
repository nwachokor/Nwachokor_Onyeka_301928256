# Portfolio 5 Discussion: Meridon Store as a Distributed Database

## Replication
Right now Meridon has one database. If that server goes down, nobody can order. With a replica, there's always a live copy. My test showed an order written on the primary showing up on the replica straight away, and the replica refusing writes, so the data can't split into two versions.

The replica is also useful for reads. Things like browsing products, order history and the reports from Portfolio 2 can run on the replica, so the primary isn't slowed down and can focus on taking orders and payments.

## Availability
If the primary fails, the replica can be promoted to become the new primary, and the store keeps going. The catch is that with normal (asynchronous) replication, the replica can be a tiny bit behind. If the primary dies at the wrong moment, the last few changes might not have reached the replica yet.

## Consistency
This is the big trade-off. If the primary and replica lose contact, Meridon has to choose:
- **Keep selling** and risk overselling, because the two might disagree about stock.
- **Stop taking orders** until they're back in sync, so the stock stays right.

For Meridon it depends on the data:
- **Stock and payments need consistency.** Selling tubs that don't exist or charging twice costs real money, which is the same problem I showed in Portfolio 3. All stock and payment writes go to the primary only.
- **Reviews and product browsing can be a bit behind.** If a new review takes a second to show up, nobody is hurt, so availability matters more there. This is part of why reviews went into MongoDB in Portfolio 4.

Synchronous replication would make the primary wait for the replica before confirming an order, so no orders are lost if the primary dies. It's safer but slower, so for Meridon I'd only consider it for payments.

## Sharding
Sharding means splitting the data across servers. Meridon already has a natural split: the Mainland and Island warehouses. Each order is fulfilled from one warehouse (rule 10), so orders and stock could be sharded by warehouse_id, with each server holding one warehouse's data.

But for Meridon right now, sharding isn't worth it:
- It's one city with two warehouses and a modest number of orders. One server handles that easily, and Portfolio 2 showed that indexes fixed the slow queries.
- Customers and products are shared by both warehouses, so they'd need to be copied to both shards or kept somewhere central.
- Queries across both warehouses, like total revenue or best sellers, would have to pull from both servers and combine the results.

Sharding makes sense later, if Meridon grows to many cities and one server can't keep up.

## Deployment
In the cloud I'd use a managed PostgreSQL service like Amazon RDS or Google Cloud SQL, with:
- A primary and a standby in different data centres, with automatic failover if the primary dies
- One read replica for browsing and reports
- Automatic daily backups, so data can be restored to an earlier point if something goes wrong
- The servers in Africa or as close to Lagos as possible, to keep things fast for customers

## Summary
Replication is the right step for Meridon now: it keeps the store running if a server fails and takes reading load off the primary. Stock and payments must stay consistent, so they're always written to the primary. Sharding by warehouse is possible, but it's not needed at Meridon's current size.
