# Portfolio 4 Document Model: Product Reviews

Meridon Store reviews are stored in MongoDB as documents in a collection called `reviews`. Each review is one document.

## Why a document model
Reviews don't all look the same. Some have photos, some rate taste and value separately, and pet reviews mention the dog or cat. Staff replies and "helpful" votes are attached to the review itself. In a relational table, most of these columns would be empty for most rows, or they'd need extra tables. A document can just include the fields it needs.

## Link to the relational database
Orders, stock and payments stay in PostgreSQL. A review only stores the IDs it needs from there:
- `product_id`: the product in PostgreSQL
- `customer_id`: the customer in PostgreSQL
- `order_id`: the order it came from, which shows it's a verified purchase

## Review document structure
| Field | Type | Always there? | Notes |
|---|---|---|---|
| `_id` | ObjectId | Yes | Created by MongoDB |
| `product_id` | Number | Yes | From PostgreSQL |
| `customer_id` | Number | Yes | From PostgreSQL |
| `order_id` | Number | Yes | Verified purchase |
| `category` | String | Yes | 'human' or 'pet' |
| `rating` | Number | Yes | 1 to 5 |
| `title` | String | Yes | |
| `comment` | String | Yes | |
| `created_at` | Date | Yes | |
| `sub_ratings` | Object | No | e.g. taste, value, results |
| `pet` | Object | No | Pet reviews only: species, name, age_years |
| `photos` | Array | No | Image file names |
| `tags` | Array | No | e.g. "fast delivery", "picky eater approved" |
| `helpful_votes` | Number | No | Starts at 0 |
| `staff_reply` | Object | No | text, staff_id, replied_at |

## Example: human product review
```json
{
  "product_id": 2,
  "customer_id": 42,
  "order_id": 1001,
  "category": "human",
  "rating": 5,
  "title": "Works well",
  "comment": "My joints feel better after a month.",
  "created_at": "2026-10-01T10:00:00Z",
  "sub_ratings": { "taste": 4, "value": 5 },
  "tags": ["fast delivery"],
  "helpful_votes": 3
}
```

## Example: pet product review
```json
{
  "product_id": 1,
  "customer_id": 87,
  "order_id": 2050,
  "category": "pet",
  "rating": 4,
  "title": "My dog loves these",
  "comment": "Took a week to get used to, now he begs for them.",
  "created_at": "2026-10-05T15:30:00Z",
  "pet": { "species": "dog", "name": "Bingo", "age_years": 6 },
  "photos": ["bingo_chews.jpg"],
  "staff_reply": {
    "text": "Thanks for sharing Bingo's progress!",
    "staff_id": 2,
    "replied_at": "2026-10-06T09:00:00Z"
  }
}
```

Both documents live in the same collection, even though they have different fields.