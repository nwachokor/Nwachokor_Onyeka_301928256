# Portfolio 5 Replication Setup

I set up two PostgreSQL servers in Docker: a primary that takes all the writes, and a replica that keeps a live copy and can only be read from.

## Steps
1. Create a network for the containers:
   `docker network create meridon-net`
2. Start the primary with replication turned on:
   `docker run --name meridon-primary --network meridon-net -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=meridon -d postgres:16 -c wal_level=replica -c max_wal_senders=5 -c hot_standby=on`
3. Create a user the replica logs in with:
   `docker exec meridon-primary psql -U postgres -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'rep';"`
4. Allow that user to connect for replication, then reload:
   `docker exec meridon-primary bash -c "echo 'host replication replicator all scram-sha-256' >> /var/lib/postgresql/data/pg_hba.conf"`
   `docker exec meridon-primary psql -U postgres -c "SELECT pg_reload_conf();"`
5. Start the replica. It copies the primary with pg_basebackup, then keeps streaming changes. It runs on port 5433:
   `docker run --name meridon-replica --network container:meridon-primary --user postgres -e PGPASSWORD=rep -d postgres:16 bash -c "pg_basebackup -h localhost -p 5432 -U replicator -D /var/lib/postgresql/data -R -X stream -c fast -v && chmod 700 /var/lib/postgresql/data && postgres -D /var/lib/postgresql/data -p 5433"`

## Problem I hit
My first try put the replica on meridon-net and connected to the primary by name. It kept failing with "connection timed out", because the containers couldn't reach each other inside Codespaces. I fixed it by running the replica inside the primary's network (`--network container:meridon-primary`) so it connects through localhost, and gave it its own port, 5433, so the two don't clash. In a real setup, the two servers would be on separate machines and connect over the network.

## Checking it works
- `docker logs meridon-replica` shows "database system is ready to accept read-only connections" (screenshots/replica_ready.png)
- On the primary, `SELECT client_addr, state FROM pg_stat_replication;` shows one row with state = streaming (screenshots/replication_streaming.png)
