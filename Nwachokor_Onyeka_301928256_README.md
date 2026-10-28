# MIT 8103 Advanced Database Systems: Practical Portfolio

**Student:** Nwachokor Onyeka (301928256)

## Case study: Meridon Store
Meridon Store is a made-up online store in Lagos that sells supplements for people and for pets (dogs and cats). It has two warehouses, Mainland and Island, its own delivery riders, and stock that's tracked by batch with expiry dates. I used this one case for all five parts.

## What's in each folder
- [Portfolio 1: Database design](portfolio-1-database-design/): I designed 10 tables, normalised them to 3NF, and wrote the schema with constraints and triggers for the business rules.
- [Portfolio 2: Query optimisation](portfolio-2-query-optimisation/): I loaded about 50,000 orders, ran five business queries, and compared EXPLAIN ANALYZE plans before and after adding indexes.
- [Portfolio 3: Transactions and concurrency](portfolio-3-transactions-concurrency/): I showed commit and rollback and two isolation levels, created an overselling race condition, and fixed it with SELECT ... FOR UPDATE.
- [Portfolio 4: NoSQL](portfolio-4-nosql/): I stored product reviews in MongoDB, because each review has different fields, and wrote queries, an update and an index.
- [Portfolio 5: Distributed and cloud](portfolio-5-distributed-cloud/): I set up a Postgres primary with a read-only replica, tested replication, and discussed scaling and cloud options.

## Final documentation
[Nwachokor_Onyeka_301928256_Final_Documentation.md](Nwachokor_Onyeka_301928256_Final_Documentation.md)

## Tools
PostgreSQL 16, MongoDB 7 and Docker, run in GitHub Codespaces.