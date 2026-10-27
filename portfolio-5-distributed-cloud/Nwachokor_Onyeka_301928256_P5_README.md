# Portfolio 5 Distributed and Cloud Databases

This portfolio sets up PostgreSQL replication for Meridon Store and discusses how the database would work across more than one server.

## What I did
- Set up a primary and a read-only replica in Docker
- Proved that changes on the primary show up on the replica
- Proved that the replica refuses writes
- Discussed replication, availability, consistency, sharding and cloud deployment for Meridon

## How to run
1. Follow the steps in `Nwachokor_Onyeka_301928256_P5_replication_setup.md`.
2. Run the statements in `Nwachokor_Onyeka_301928256_P5_replication_test.sql`: step 1 on the primary (port 5432), steps 2 and 3 on the replica (port 5433).

## Files
| File / folder | What it contains |
|---|---|
| `Nwachokor_Onyeka_301928256_P5_replication_setup.md` | Docker steps, and the network problem I hit and fixed |
| `Nwachokor_Onyeka_301928256_P5_replication_test.sql` | The write, read and refused-write tests |
| `Nwachokor_Onyeka_301928256_P5_discussion.md` | Replication, availability, consistency, sharding and deployment for Meridon |
| `screenshots/` | Evidence for each step |

## Evidence
| Screenshot | What it shows |
|---|---|
| replica_ready.png | Replica started and ready for read-only connections |
| replication_streaming.png | Primary shows the replica connected and streaming |
| replica_read.png | Order written on the primary, read from the replica |
| replica_write_refused.png | Replica refuses a write |

## Summary
Replication keeps Meridon running if a server fails and spreads out the reading load. Stock and payments stay consistent by always writing to the primary. Sharding by warehouse is possible but not needed at Meridon's current size.
