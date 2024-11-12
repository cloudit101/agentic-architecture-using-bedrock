-- Insert data into category table
INSERT INTO category (id, name) VALUES
    (1, 'Dogs'),
    (2, 'Cats'),
    (3, 'Birds'),
    (4, 'Fish'),
    (5, 'Reptiles');

-- Insert data into pet table
INSERT INTO pet (id, name, category, photourls, status) VALUES
    (1, 'Buddy', 1, ARRAY[
        'http://example.com/photos/buddy1.jpg',
        'http://example.com/photos/buddy2.jpg'
    ], 'available'),
    (2, 'Whiskers', 2, ARRAY[
        'http://example.com/photos/whiskers1.jpg'
    ], 'pending'),
    (3, 'Tweety', 3, ARRAY[
        'http://example.com/photos/tweety1.jpg'
    ], 'sold'),
    (4, 'Nemo', 4, ARRAY[
        'http://example.com/photos/nemo1.jpg'
    ], 'available'),
    (5, 'Slinky', 5, ARRAY[
        'http://example.com/photos/slinky1.jpg'
    ], 'available');

-- Insert data into customer table
INSERT INTO customer (id, username) VALUES
    (1, 'john_doe'),
    (2, 'jane_smith'),
    (3, 'alice_jones'),
    (4, 'bob_brown'),
    (5, 'charlie_black');

-- Insert data into address table
INSERT INTO address (id, customerid, street, city, state, zip) VALUES
    (1, 1, '123 Maple Street', 'Springfield', 'IL', '62704'),
    (2, 2, '456 Oak Avenue', 'Shelbyville', 'IL', '62565'),
    (3, 3, '789 Pine Road', 'Capital City', 'IL', '62701'),
    (4, 4, '321 Birch Blvd', 'Ogdenville', 'IL', '62234'),
    (5, 5, '654 Cedar Lane', 'North Haverbrook', 'IL', '62890');

-- Insert data into user table
INSERT INTO "user" (id, customerid, username, firstname, lastname, email, password, phone, userstatus) VALUES
    (1, 1, 'john_doe', 'John', 'Doe', 'john.doe@example.com', 'securepassword123', '555-1234', 1),
    (2, 2, 'jane_smith', 'Jane', 'Smith', 'jane.smith@example.com', 'anothersecurepwd', '555-5678', 1),
    (3, 3, 'alice_jones', 'Alice', 'Jones', 'alice.jones@example.com', 'alicepass', '555-9012', 1),
    (4, 4, 'bob_brown', 'Bob', 'Brown', 'bob.brown@example.com', 'bobsecure', '555-3456', 0),
    (5, 5, 'charlie_black', 'Charlie', 'Black', 'charlie.black@example.com', 'charliepwd', '555-7890', 1);

-- Insert data into tag table
INSERT INTO tag (id, name) VALUES
    (1, 'Friendly'),
    (2, 'Energetic'),
    (3, 'Calm'),
    (4, 'Playful'),
    (5, 'Lazy');

-- Insert data into order table
INSERT INTO "order" (id, customerid, petid, quantity, shipdate, status, complete) VALUES
    (1, 1, 1, 2, '2024-10-01 10:00:00', 'pending', FALSE),
    (2, 2, 3, 1, '2024-09-20 15:30:00', 'shipped', TRUE),
    (3, 1, 4, 1, '2024-10-05 09:00:00', 'pending', FALSE),
    (4, 3, 2, 3, '2024-09-25 14:00:00', 'delivered', TRUE),
    (5, 4, 5, 1, '2024-10-10 11:30:00', 'processing', FALSE),
    (6, 5, 1, 1, '2024-09-30 16:45:00', 'shipped', TRUE),
    (7, 2, 4, 2, '2024-10-12 08:15:00', 'pending', FALSE),
    (8, 3, 5, 1, '2024-10-18 13:20:00', 'processing', FALSE),
    (9, 5, 2, 4, '2024-10-22 17:50:00', 'pending', FALSE),
    (10, 4, 3, 2, '2024-10-25 12:00:00', 'delivered', TRUE);

-- Insert data into pettag table
INSERT INTO pettag (petid, tagid) VALUES
    (1, 1),  -- Buddy is Friendly
    (1, 2),  -- Buddy is Energetic
    (2, 3),  -- Whiskers is Calm
    (3, 4),  -- Tweety is Playful
    (4, 2),  -- Nemo is Energetic
    (4, 5),  -- Nemo is Lazy
    (5, 3),  -- Slinky is Calm
    (5, 5),  -- Slinky is Lazy
    (2, 1),  -- Whiskers is Friendly
    (3, 2);  -- Tweety is Energetic