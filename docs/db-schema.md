# Tutta – Database Schema

## 1. users

Stores all users of the platform.

Fields:
- id
- full_name
- phone
- email
- password_hash
- role (guest, host, premium_host, admin)
- profile_image
- created_at
- updated_at

---

## 2. listings

Stores homes or rooms created by hosts.

Fields:
- id
- host_id
- title
- description
- country
- city
- district
- address
- latitude
- longitude
- property_type
- room_type
- daily_price
- weekly_price
- monthly_price
- is_active
- created_at
- updated_at

---

## 3. listing_images

Stores images for each listing.

Fields:
- id
- listing_id
- image_url
- sort_order
- created_at

---

## 4. bookings

Stores booking records.

Fields:
- id
- listing_id
- guest_id
- start_date
- end_date
- total_price
- status (pending, confirmed, cancelled, completed)
- created_at
- updated_at

---

## 5. reviews

Stores ratings and reviews.

Fields:
- id
- booking_id
- reviewer_id
- review_target_id
- rating
- comment
- created_at

---

## 6. chats

Stores chat rooms between guest and host.

Fields:
- id
- booking_id
- host_id
- guest_id
- created_at

---

## 7. messages

Stores chat messages.

Fields:
- id
- chat_id
- sender_id
- message_text
- message_type
- created_at

---

## 8. payments

Stores payment information.

Fields:
- id
- booking_id
- user_id
- amount
- payment_method
- payment_status
- transaction_id
- created_at

---

## 9. premium_subscriptions

Stores premium host subscriptions.

Fields:
- id
- user_id
- start_date
- end_date
- status
- created_at

---

## 10. skill_exchange_listings

Stores free stay / skill-based stay information.

Fields:
- id
- listing_id
- required_skill
- description
- is_premium_only
- created_at
