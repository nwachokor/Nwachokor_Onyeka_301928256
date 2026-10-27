// Portfolio 4: sample product reviews for Meridon Store
// Run inside mongosh after: use meridon
// Safe to run again: it clears the collection first.

db.reviews.deleteMany({});

db.reviews.insertMany([
  // Human product reviews
  {
    product_id: 2, customer_id: 42, order_id: 1001, category: "human",
    rating: 5, title: "Works well",
    comment: "My joints feel better after a month.",
    created_at: new Date("2026-10-01T10:00:00Z"),
    sub_ratings: { taste: 4, value: 5 },
    tags: ["fast delivery"], helpful_votes: 3
  },
  {
    product_id: 2, customer_id: 115, order_id: 1210, category: "human",
    rating: 3, title: "Okay, but big tablets",
    comment: "Does the job but the tablets are hard to swallow.",
    created_at: new Date("2026-10-08T08:15:00Z"),
    sub_ratings: { taste: 2, value: 3 },
    helpful_votes: 1
  },
  {
    product_id: 4, customer_id: 230, order_id: 1402, category: "human",
    rating: 4, title: "Good value",
    comment: "Cheaper than the pharmacy and arrived the next day.",
    created_at: new Date("2026-10-10T12:40:00Z"),
    sub_ratings: { value: 5, results: 4 },
    tags: ["fast delivery", "good price"]
  },
  {
    product_id: 6, customer_id: 512, order_id: 1888, category: "human",
    rating: 2, title: "No change yet",
    comment: "Two weeks in and I haven't noticed anything.",
    created_at: new Date("2026-10-15T19:05:00Z"),
    staff_reply: {
      text: "Most customers see results after 4 to 6 weeks. Let us know how it goes!",
      staff_id: 1, replied_at: new Date("2026-10-16T09:00:00Z")
    }
  },

  // Pet product reviews: dogs
  {
    product_id: 1, customer_id: 87, order_id: 2050, category: "pet",
    rating: 4, title: "My dog loves these",
    comment: "Took a week to get used to, now he begs for them.",
    created_at: new Date("2026-10-05T15:30:00Z"),
    pet: { species: "dog", name: "Bingo", age_years: 6 },
    photos: ["bingo_chews.jpg"],
    staff_reply: {
      text: "Thanks for sharing Bingo's progress!",
      staff_id: 2, replied_at: new Date("2026-10-06T09:00:00Z")
    }
  },
  {
    product_id: 1, customer_id: 301, order_id: 2101, category: "pet",
    rating: 5, title: "Stiff joints much better",
    comment: "My old boy climbs the stairs again.",
    created_at: new Date("2026-10-12T07:20:00Z"),
    pet: { species: "dog", name: "Rex", age_years: 11 },
    tags: ["senior dog"], helpful_votes: 7
  },
  {
    product_id: 5, customer_id: 640, order_id: 2333, category: "pet",
    rating: 3, title: "Too big for a small dog",
    comment: "Had to break them in half for my puppy.",
    created_at: new Date("2026-10-18T16:45:00Z"),
    pet: { species: "dog", name: "Coco", age_years: 1 },
    photos: ["coco_1.jpg", "coco_2.jpg"]
  },

  // Pet product reviews: cats
  {
    product_id: 3, customer_id: 77, order_id: 2210, category: "pet",
    rating: 5, title: "Picky cat approved",
    comment: "She eats it mixed into her food with no fuss.",
    created_at: new Date("2026-10-09T11:10:00Z"),
    pet: { species: "cat", name: "Mimi", age_years: 4 },
    tags: ["picky eater approved"], helpful_votes: 5
  },
  {
    product_id: 3, customer_id: 902, order_id: 2455, category: "pet",
    rating: 1, title: "Wouldn't touch it",
    comment: "My cat sniffed it and walked away.",
    created_at: new Date("2026-10-20T20:30:00Z"),
    pet: { species: "cat", name: "Tiger", age_years: 3 },
    staff_reply: {
      text: "Sorry about that. Try a small amount mixed into wet food first.",
      staff_id: 2, replied_at: new Date("2026-10-21T10:00:00Z")
    }
  },
  {
    product_id: 7, customer_id: 1450, order_id: 2600, category: "pet",
    rating: 4, title: "Shinier coat",
    comment: "Noticed a softer coat after three weeks.",
    created_at: new Date("2026-10-22T09:55:00Z"),
    pet: { species: "cat", name: "Snow", age_years: 7 },
    sub_ratings: { results: 4, value: 4 }
  }
]);

// Check: should show 10
db.reviews.countDocuments();