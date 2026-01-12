-- Seed data for Resident Directory Management System
-- Notes:
--  - password_hash is a placeholder to be replaced by backend hashing later.
--  - Photo URLs are placeholders (non-Cloudinary) and can be replaced later.

BEGIN;

-- Admin user seed (id deterministic for convenience)
INSERT INTO users (id, email, password_hash, role)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin@example.com',
    'CHANGE_ME_HASH_LATER',
    'admin'
)
ON CONFLICT (email) DO NOTHING;

-- Sample residents
INSERT INTO residents (first_name, last_name, address, city, state, zip, phone, email, photo_url, photo_public_id, notes)
VALUES
('Ava', 'Johnson', '123 Maple St', 'Springfield', 'IL', '62701', '555-0101', 'ava.johnson@example.com',
 'https://example.com/photos/ava-johnson.jpg', 'placeholder_ava_johnson', 'Prefers email contact.'),
('Liam', 'Martinez', '456 Oak Ave', 'Springfield', 'IL', '62702', '555-0102', 'liam.martinez@example.com',
 'https://example.com/photos/liam-martinez.jpg', 'placeholder_liam_martinez', 'Has a service dog.'),
('Sophia', 'Chen', '789 Pine Rd', 'Madison', 'WI', '53703', '555-0103', 'sophia.chen@example.com',
 'https://example.com/photos/sophia-chen.jpg', 'placeholder_sophia_chen', 'Emergency contact on file.'),
('Noah', 'Patel', '1010 Cedar Blvd', 'Madison', 'WI', '53704', '555-0104', 'noah.patel@example.com',
 'https://example.com/photos/noah-patel.jpg', 'placeholder_noah_patel', 'Likes printed notices.'),
('Emma', 'Williams', '2020 Birch Ln', 'Austin', 'TX', '73301', '555-0105', 'emma.williams@example.com',
 'https://example.com/photos/emma-williams.jpg', 'placeholder_emma_williams', 'Moved in recently.');

COMMIT;
